class Deployment < ActiveRecord::Base
  belongs_to :project
  belongs_to :environment

  has_one :commit
end
