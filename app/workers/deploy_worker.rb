class DeployWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(location_id)
    location = Location.find(location_id)
    location.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    location.worker.running!
    location.save

    notification_deployment = nil

    begin
      repo = Pbtd::GitRepository.new
      repo.open(location.project.name)
      repo.fetch
      repo.checkout(location.branch)
      repo.merge(location.branch)

      project_path = File.join(SETTINGS["repositories_path"], location.project.name)

      deploy(location, project_path)

      location.worker.success!

      location.update_distance

      notification_message = { state: 'success', location_id: location.id }
    rescue => e
      location.worker.error_class_name = e.class.name
      location.worker.error_message = e.message
      location.worker.failure!
      notification_message = { state: 'failure', location_id: location.id, message: e.message }
      raise e
    ensure
    end
  end

  def deploy(location, project_path)
    begin
      input, output = IO.pipe
      pid = spawn("cd #{project_path} && cap #{location.name} deploy", out: output)
      loop do
        # Do not wait more than 2 seconds for an input, the process could be exited
        Timeout::timeout(2) do
          # Read one line at a time continuously
          loop do
            chunck = input.readline
            notification_message = { state: 'running', location_id: location.id, message: chunck }
            send_notification(notification_message)
          end
        end rescue nil

        # Check if the process is still alive
        break if Process.waitpid(pid, Process::WNOHANG)
      end

      # Read the rest of the output (just in case)
      # You should also choose a better suited number than 100000 depending on your command
      remaining_chunck = output.read_nonblock(100000) rescue nil
      if remaining_chunck
        notification_message = { state: 'running', location_id: location.id, message: remaining_chunck }
        send_notification(notification_message)
      end

      # Display finish
      state = $?.success? ? "success" : "failed"
      notification_message = { state: state, location_id: location.id }
      send_notification(notification_message)
    end
  end

  def send_notification(data)
    EM.run do
      message = Faye::Client.new(SETTINGS['faye_server']).publish('/deploy_notifications', data)
      message.callback { EM.stop }
    end
  end
end
