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
  repository_url { sequence(:repository_url) { |i|  "git@github.com:synbioz/pbtd#{i}.git"} }
end

Fabricator(:valid_project, from: :project) do
  name           "pbtd"
  repository_url "git@github.com:synbioz/pbtd.git"
end

Fabricator(:invalid_project, from: :valid_project) do
  name           ""
  repository_url "git@github.com:synbioz/invalid_pbtd.git"
end

Fabricator(:project_deploy, from: :project) do
  name nil
  repository_url "git@github.com:synbioz/pbtd.git"
end

Fabricator(:invalid_project_deploy, from: :project_deploy) do
  repository_url "git@github.com:synbioz/invalid_pbtd.git"
end

