class DistanceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(location_id)
    location = Location.find(location_id)

    location.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    location.worker.running!
    location.save

    begin
      repo = Pbtd::GitRepository.new
      repo.open(location.project.name)
      repo.fetch
      repo.checkout(location.branch)

      distance = repo.get_behind(location.branch, location.get_current_release_commit)

      location.update_attribute(:distance, distance)

      location.worker.success!
    rescue => e
      location.worker.error_class_name = e.class.name
      location.worker.error_message = e.message
      location.worker.failure!
      raise e
    end
  end
end
