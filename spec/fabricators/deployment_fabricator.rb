# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  location_id :integer
#  commit_id   :integer
#  status      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

Fabricator(:deployment) do
  commit      { Fabricate(:commit) }
  location    { Fabricate(:location) }
  status      1
end
