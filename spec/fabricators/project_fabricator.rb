# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  repository_url :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  worker_id      :integer
#

Fabricator(:project) do
  name           { Faker::Name.name }
  repository_url { Faker::Internet.url }
end
