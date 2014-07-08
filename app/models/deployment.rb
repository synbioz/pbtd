# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  location_id :integer
#  status      :integer
#  finish_at   :date
#  created_at  :datetime
#  updated_at  :datetime
#

class Deployment < ActiveRecord::Base
  belongs_to :project, inverse_of: :deployments
  belongs_to :location, inverse_of: :deployments

  has_one :commit, inverse_of: :deployment

  enum status: [ :running, :pending, :success, :failure ]

  validates_presence_of :project, :location, :finish_at
end
