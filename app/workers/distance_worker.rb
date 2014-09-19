class DistanceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  #
  # method permit to catch the current commit id of project on the remote server for specific location
  # notify user with pub/sub faye server in Event Machine
  # @param location_id [Integer] [id of Location object]
  #
  # @return [String] [sidekiq job id]
  def perform(location_id)
    location = Location.find(location_id)
    location.worker.destroy if location.worker
    location.create_worker(job_id: self.jid, class_name: self.class.name)
    location.worker.running!
    location.save

    notification_message = nil
    begin
      repo = Pbtd::GitRepository.new
      repo.open(location.project.repo_name)
      repo.checkout(location.branch)
      repo.fetch

      location.check_ruby_version

      current_release_commit = location.get_current_release_commit
      distance = repo.get_behind(location.branch, current_release_commit)
      location.update_attribute(:distance, distance)
      location.worker.success!

      repo.checkout(SETTINGS['default_branch'])
      repo.close

      notification_message = { state: 'success', location_id: location.id, distance: distance }
    rescue => e
      location.update_attribute(:distance, -1)
      location.worker.fail_with!(e)
      notification_message = { state: 'failure', location_id: location.id, message: e.message }
    ensure
        message = {:channel => '/distance_notifications', :data => notification_message}
        uri = URI.parse(SETTINGS['faye_server'])
        Net::HTTP.post_form(uri, :message => message.to_json)
    end
  end
end
