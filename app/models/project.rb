# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  repository_url :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  worker_id      :integer
#

class Project < ActiveRecord::Base
  has_many :locations, -> { order(:name) }, class_name: "Location", dependent: :destroy
  belongs_to :worker, dependent: :destroy

  GIT_REGEX = /\w*@[a-z0-9]*\.[a-z0-9]*.[a-z0-9]*\:\w*\/[0-9a-z\-_]*\.git/

  validates :name, presence: true, uniqueness: true, on: :update
  validates :repository_url, presence: true, uniqueness: true, format: { with: GIT_REGEX }

  before_create :name_from_repository_url
  after_create :cloning_repository

  after_destroy :rm_physic_folder

  accepts_nested_attributes_for :locations

  attr_accessor :default_branch

  #
  # use to preload environments for git repository of project
  #
  # @return [Array] [array of Location objects]
  def preload_environments
    reader = Pbtd::CapistranoReader.new(self.repo_name)
    reader.environments.each do |env|
      branch = reader.branch(env)
      url = reader.url(env)
      self.locations.create(name: env, branch: branch, application_url: url) unless self.locations.exists?(name: env)
    end
  end

  #
  # load error from worker association model
  #
  # @return [void]
  def load_errors
    self.errors.add(:git_repository, self.worker.error_message)
  end

  #
  # load branches of repository url
  #
  # @return [Array] [all git remotes branches]
  def load_branches
    repo = Pbtd::GitRepository.new
    repo.open(self.repo_name)
    repo.remote_branches
  end

  #
  # update distance from deploy for locations
  #
  # @return [void]
  def update_locations_distance
    self.locations.each do |location|
      location.update_distance
    end
  end


  #
  # launch update_locations_distance on each project
  #
  # @return [void]
  def self.update_all_locations
    Project.all.map(&:update_locations_distance)
  end

  #
  # name of project from repository_url
  #
  # @return [String]
  def repo_name
    self.repository_url.split('/').last.split('.').first if self.repository_url.present?
  end

  private

    #
    # clone repository of project asynchronous
    #
    # @return [void]
    def cloning_repository
      GitCloneWorker.perform_async(self.id, self.default_branch) if self.worker.nil? || self.worker.failure?
    end

    #
    # remote folder where stored the git repository of project
    #
    # @return [void]
    def rm_physic_folder
      project_path = File.join(SETTINGS["repositories_path"], self.repo_name)
      FileUtils.rm_rf(project_path)
      `rm #{Rails.root}/log/#{self.repo_name}*`
    end

    #
    # name of project from repository_url
    #
    # @return [void]
    def name_from_repository_url
      self.name = self.repo_name
    end
end
