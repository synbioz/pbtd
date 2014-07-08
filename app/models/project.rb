# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  repository_url :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Project < ActiveRecord::Base
  has_many :locations, inverse_of: :project
  has_many :deployments, inverse_of: :project

  validates :name, presence: true, uniqueness: true
  validates :repository_url, presence: true, uniqueness: true
end
