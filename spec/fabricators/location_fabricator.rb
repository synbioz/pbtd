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
#  distance        :integer
#

Fabricator(:location) do
  project         { Fabricate(:project) }
  name            { Faker::Name.name }
  branch          { Faker::Name.name }
  application_url { Faker::Internet.url }
  distance        { Faker::Number.digit }
  worker
end
