class DeployWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  #
  # launch the deployment && create commit and deployment objects relation for history
  # use GitRepository lib to checkout in correct branch for this location
  # @param location_id [Integer] [id of Location object]
  #
  # @return [String] [sidekiq job id]
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
      send_notification(notification_message)
    rescue => e
      deployment.failure!
      location.worker.error_class_name = e.class.name
      location.worker.error_message = e.message
      location.worker.failure!
      notification_message = { state: 'failure', location_id: location.id, message: e.message }
      send_notification(notification_message)
    end
  end

  #
  # Launch capistrano deploy in sub process with popen && notify user with pub/sub
  # @param location [Integer] [id of Location object]
  # @param project_path [String] [path of the project git repository]
  #
  # @return [void]
  def deploy(location, project_path)
    logger = Logger.new("#{Rails.root}/log/#{location.project.repo_name}.log")

    cmd = "cd #{project_path} && #{SETTINGS['ssh_agent_script']} #{clean_env} bundle exec cap #{location.name} deploy"

    cmd += " -l STDOUT" if location.cap_version < "3.0.0"

    IO.popen(cmd).each do |line|
      notification_message = { state: 'running', location_id: location.id, message: line }
      send_notification(notification_message)
      logger.info(line)
    end.close

    state = $?.success? ? "success" : "failed"
  end

  #
  # Connection to Faye pub/sub server to push new messages
  # @param data [Hash] [contain the state of deployment, the location id and the capistrano return]
  #
  # @return [void]
  def send_notification(data)
    message = {:channel => '/deploy_notifications', :data => data}
    uri = URI.parse(SETTINGS['faye_server'])
    Net::HTTP.post_form(uri, :message => message.to_json)
  end


  #
  # linux shell command to clean the env variable
  #
  # @return [String] [command shell linux]
  def clean_env
    "env -i HOME=$HOME LC_CTYPE=${LC_ALL:-${LC_CTYPE:-$LANG}} PATH=$PATH USER=$USER SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID"
  end
end
