# == Schema Information
#
# Table name: locations
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  name            :string(255)
#  branch          :string(255)
#  application_url :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  distance        :integer
#

class Location < ActiveRecord::Base
  has_many :deployments, inverse_of: :location
  has_many :commits, inverse_of: :location

  belongs_to :project, inverse_of: :locations

  validates_presence_of :name, :branch, :application_url, :project

  #
  # Return distance between branch and deployed commit
  #
  # @return [Integer]
  def get_distance_from_release
    repo = Pbtd::GitRepository.new
    repo.open(self.project.name)
    repo.fetch
    repo.checkout(self.branch)
    repo.get_behind(self.branch, release_commit_sha)
  end

  #
  # get current commit sha on remote server
  #
  # @return [String] [git commit sha]
  def get_current_release_commit
    cap_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano')
    project_path = File.join(SETTINGS["repositories_path"], self.project.name)

    `cd #{project_path} && bundle install`
    `cd #{project_path} && cap #{self.name} -R #{cap_lib_path} remote:fetch_revision`.strip
  end


  #
  # fetch distance from remote server for location
  #
  # @return [String] [Sidekiq job_id]
  def update_distance
    DistanceWorker.perform_async(self.id)
  end
end
