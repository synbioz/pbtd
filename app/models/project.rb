class Project < ActiveRecord::Base
  has_many :environments, inverse_of: :project
  has_many :deployments, inverse_of: :project

  validates :name, presence: true, uniqueness: true
  validates :repository_url, presence: true, uniqueness: true
end
