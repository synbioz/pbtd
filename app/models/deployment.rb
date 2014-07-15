# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  location_id :integer
#  commit_id   :integer
#  status      :integer
#  finished_at :date
#  created_at  :datetime
#  updated_at  :datetime
#

class Deployment < ActiveRecord::Base
  belongs_to :location, inverse_of: :deployments
  belongs_to :commit, inverse_of: :deployments

  enum status: [ :running, :success, :failure ]

  validates_presence_of :location, :finished_at
end
