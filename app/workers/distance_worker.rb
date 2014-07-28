class DistanceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(location_id)
    location = Location.find(location_id)

    repo = Pbtd::GitRepository.new
    repo.open(location.project.name)
    repo.fetch
    repo.checkout(location.branch)

    distance = repo.get_behind(location.branch, location.get_current_release_commit)

    location.update_attribute(:distance, distance)
  end
end
