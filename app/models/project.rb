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
  has_many :locations, inverse_of: :project, class_name: "Location"
  belongs_to :worker

  GIT_REGEX = /\w*@[a-z0-9]*\.[a-z0-9]*.[a-z0-9]*\:\w*\/[0-9a-z\-_]*\.git/

  validates :name, presence: true, uniqueness: true
  validates :repository_url, presence: true, uniqueness: true, format: { with: GIT_REGEX }

  after_create :cloning_repository

  accepts_nested_attributes_for :locations

  #
  # use to preload environments for git repository of project
  #
  # @return [Array] [array of Location objects]
  def preload_environments
    reader = Pbtd::CapistranoReader.new(self.name)
    reader.environments.each do |env|
      branch = reader.branch(env)
      url = reader.url(env)
      self.locations.build(name: env, branch: branch, application_url: url)
    end
  end

  private

    #
    # clone repository of project asynchronous
    #
    def cloning_repository
      GitCloneWorker.perform_async(self.id)
    end
end
