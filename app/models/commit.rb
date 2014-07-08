# == Schema Information
#
# Table name: commits
#
#  id            :integer          not null, primary key
#  deployment_id :integer
#  name          :string(255)
#  sha1          :string(255)
#  user          :string(255)
#  commit_date   :date
#  created_at    :datetime
#  updated_at    :datetime
#

class Commit < ActiveRecord::Base
  belongs_to :deployment, inverse_of: :commit

  validates_presence_of :user, :sha1, :name, :deployment, :commit_date
  validates :sha1, uniqueness: true
end
