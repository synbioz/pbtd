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
  has_many :locations, inverse_of: :project
  belongs_to :worker

  GIT_REGEX = /\w*@[a-z]*\.[a-z]*.[a-z]*\:\w*\/[a-z\-_]*\.git/

  validates :name, presence: true, uniqueness: true
  validates :repository_url, presence: true, uniqueness: true, format: { with: GIT_REGEX }

  after_create :cloning_repository

  private

    def cloning_repository
      GitCloneWorker.perform_async(self.id)
    end
end
