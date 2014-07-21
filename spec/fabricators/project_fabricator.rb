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
  repository_url { "git@git."+Faker::Name.last_name.downcase+".com:synbioz/pbtd.git" }
end
