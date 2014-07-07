class Environment < ActiveRecord::Base
  belongs_to :project

  has_many :deployments
end
