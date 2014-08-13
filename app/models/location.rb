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
#  worker_id       :integer
#

class Location < ActiveRecord::Base
  has_many :deployments, dependent: :destroy
  has_many :commits, dependent: :destroy

  belongs_to :project
  belongs_to :worker, dependent: :destroy

  validates_presence_of :name, :branch, :application_url, :project

  after_commit :update_distance, on: :create

  #
  # deploy current location to remote server
  #
  # @return [void]
  def deploy
    DeployWorker.perform_async(self.id)
  end

  #
  # get current commit sha on remote server
  #
  # @return [String] [git commit sha]
  def get_current_release_commit
    cap_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano')
    project_path = File.join(SETTINGS["repositories_path"], self.project.repo_name)

    `cd #{project_path} 2> /dev/null && bundle install 2> /dev/null`
    logger.debug "bundle install cannot be accomplished in #{project_path}" unless $?.success?

    sha = `cd #{project_path} 2> /dev/null && cap #{self.name} -R #{cap_lib_path} remote:fetch_revision 2> /dev/null`.strip

    unless $?.success?
      logger.debug "cap remote:fetch_revision cannot be accomplished in #{project_path}"
      raise "cannot fetch remote host #{self.application_url}"
    end

    return sha
  end


  #
  # fetch distance from remote server for location
  #
  # @return [String] [Sidekiq job_id]
  def update_distance
    DistanceWorker.perform_async(self.id)
  end
end
