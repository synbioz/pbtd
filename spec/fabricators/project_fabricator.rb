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
  repository_url { sequence(:repository_url) { |i|  "git@git.synbioz#{i}.com:/pbtd.git"} }
end

Fabricator(:valid_project, from: :project) do
  name           "academy"
  repository_url "git@git.synbioz.com:synbioz/academy.git"
end

Fabricator(:invalid_project, from: :valid_project) do
  repository_url "git.synbioz.com"
end

Fabricator(:project_deploy, from: :project) do
  name nil
  repository_url "git@git.synbioz.com:synbioz/deploy_test.git"
end
