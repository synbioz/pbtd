# == Schema Information
#
# Table name: locations
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  name            :string(255)
#  branch          :string(255)
#  application_url :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Location < ActiveRecord::Base
  has_many :deployments, inverse_of: :location

  belongs_to :project, inverse_of: :locations
end
