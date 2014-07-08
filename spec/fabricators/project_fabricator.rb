Fabricator(:project) do
  name           { Faker::Name.name }
  repository_url { Faker::Internet.url }
end
