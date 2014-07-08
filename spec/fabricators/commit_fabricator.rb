# == Schema Information
#
# Table name: commits
#
#  id          :integer          not null, primary key
#  location_id :integer
#  name        :string(255)
#  sha1        :string(255)
#  user        :string(255)
#  commit_date :date
#  created_at  :datetime
#  updated_at  :datetime
#

Fabricator(:commit) do
  location    { Fabricate(:location) }
  name        { Faker::Name.name }
  sha1        { Faker::Number.number(10) }
  user        { Faker::Name.name }
  commit_date { Date.today - Faker::Number.number(3).to_i.days }
end
