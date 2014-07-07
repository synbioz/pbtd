class Deployment < ActiveRecord::Base
  belongs_to :project, inverse_of: :deployments
  belongs_to :environment, inverse_of: :deployments

  has_one :commit, inverse_of: :deployment
end
