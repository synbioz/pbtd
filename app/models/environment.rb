class Environment < ActiveRecord::Base
  belongs_to :project, inverse_of: :environments

  has_many :deployments, inverse_of: :environment
end
