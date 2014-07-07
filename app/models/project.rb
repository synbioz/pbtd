class Project < ActiveRecord::Base
  has_many :environments, inverse_of: :project
  has_many :deployments, inverse_of: :project
end
