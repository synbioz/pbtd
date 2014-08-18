# == Schema Information
#
# Table name: commits
#
#  id          :integer          not null, primary key
#  location_id :integer
#  name        :string(255)
#  sha1        :string(255)
#  user        :string(255)
#  commit_date :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Commit < ActiveRecord::Base
  belongs_to :location, inverse_of: :commits
  has_many :deployments, inverse_of: :commit

  validates_presence_of :user, :sha1, :name, :commit_date
  validates :sha1, presence: true, uniqueness: true
end
