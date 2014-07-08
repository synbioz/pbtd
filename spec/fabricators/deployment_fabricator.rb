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

Fabricator(:deployment) do
  project   { Fabricate(:project) }
  location  { Fabricate(:location) }
  status    1
  finish_at { Date.today - Faker::Number.number(3).to_i.days }
end
