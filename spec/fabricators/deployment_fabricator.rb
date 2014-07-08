# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  location_id :integer
#  state       :string(255)
#  finish_at   :date
#  created_at  :datetime
#  updated_at  :datetime
#

Fabricator(:deployment) do
  project   { Fabricate(:project) }
  location  { Fabricate(:location) }
  state     { Faker::Name.name }
  finish_at { Date.today - Faker::Number.number(3).to_i.days }
end
