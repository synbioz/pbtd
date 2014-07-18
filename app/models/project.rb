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

  validates :name, presence: true, uniqueness: true
  validates :repository_url, presence: true, uniqueness: true
end
