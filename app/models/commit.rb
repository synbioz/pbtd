class Commit < ActiveRecord::Base
  belongs_to :deployment, inverse_of: :commit
end
