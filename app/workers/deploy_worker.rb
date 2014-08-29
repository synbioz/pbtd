class DeployWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(location_id)
    location = Location.find(location_id)
    location.worker.destroy if location.worker
    location.create_worker(job_id: self.jid, class_name: self.class.name)
    location.worker.running!
    location.save

    deployment = location.deployments.create
    deployment.running!

    notification_deployment = nil

    begin
      repo = Pbtd::GitRepository.new
      repo.open(location.project.repo_name)
      repo.fetch
      repo.checkout(location.branch)

      location.check_ruby_version

      commit_information = repo.last_commit(location.branch)

      commit = location.commits.create_with(name: commit_information.message.strip, user: commit_information.author[:name], commit_date: commit_information.author[:time].to_datetime).find_or_create_by(sha1: commit_information.oid)

      deployment.update_attribute(:commit_id, commit.id)

      project_path = File.join(SETTINGS["repositories_path"], location.project.repo_name)

      deploy(location, project_path)

      deployment.success!
      location.worker.success!
      location.update_distance

      repo.checkout(SETTINGS['default_branch'])
      repo.close

      notification_message = { state: 'success', location_id: location.id }
    rescue => e
      deployment.failure!
      location.worker.error_class_name = e.class.name
      location.worker.error_message = e.message
      location.worker.failure!
      notification_message = { state: 'failure', location_id: location.id, message: e.message }
    end
  end

  def deploy(location, project_path)
    logger = Logger.new("#{Rails.root}/log/#{location.project.repo_name}.log")

    cmd = "cd #{project_path} && #{SETTINGS['ssh_agent_script']} #{clean_env} bundle exec cap #{location.name} deploy"

    IO.popen(cmd).each do |line|
      notification_message = { state: 'running', location_id: location.id, message: line }
      send_notification(notification_message)
      logger.info(line)
    end.close

    # Display finish
    state = $?.success? ? "success" : "failed"
    notification_message = { state: state, location_id: location.id }
    send_notification(notification_message)
  end

  def send_notification(data)
    EM.run do
      message = Faye::Client.new(SETTINGS['faye_server']).publish('/deploy_notifications', data)
      message.callback { EM.stop }
    end
  end

  def clean_env
    "env -i HOME=$HOME LC_CTYPE=${LC_ALL:-${LC_CTYPE:-$LANG}} PATH=$PATH USER=$USER SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID"
  end
end
