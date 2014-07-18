# == Schema Information
#
# Table name: workers
#
#  id               :integer          not null, primary key
#  job_id           :string(255)
#  class_name       :string(255)
#  status           :integer
#  error_class_name :string(255)
#  error_message    :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

Fabricator(:worker) do
  job_id           { Faker::Name.name }
  class_name       { Faker::Name.name }
  status           1
  error_class_name { Faker::Name.name }
  error_message    { Faker::Name.name }
end
