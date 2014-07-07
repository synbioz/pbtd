class Commit < ActiveRecord::Base
  belongs_to :deployment
end
