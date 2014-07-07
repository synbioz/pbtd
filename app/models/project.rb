class Project < ActiveRecord::Base
  has_many :environments
  has_many :deployments
end
