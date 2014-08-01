class DistanceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(location_id)
    location = Location.find(location_id)
    location.worker.destroy if location.worker
    location.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    location.worker.running!
    location.save

    notification_message = nil

    begin
      repo = Pbtd::GitRepository.new
      repo.open(location.project.name)
      repo.fetch
      repo.checkout(location.branch)

      distance = repo.get_behind(location.branch, location.get_current_release_commit)

      location.update_attribute(:distance, distance)
      location.worker.success!

      notification_message = { state: 'success', location_id: location.id, distance: distance }

      repo.close
    rescue => e
      location.worker.error_class_name = e.class.name
      location.worker.error_message = e.message
      location.worker.failure!
      notification_message = { state: 'failure', location_id: location.id, message: e.message }
      raise e
    ensure
      EM.run do
        client = Faye::Client.new(SETTINGS['faye_server'])
        message = client.publish('/distance_notifications', notification_message)
        message.callback do
          EM.stop
        end
      end
    end
  end
end
