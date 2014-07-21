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

class Worker < ActiveRecord::Base

  before_create :init_status

  enum status: [ :pending, :running, :success, :failure ]

  validates :job_id, presence: true
  validates :class_name, presence: true

  private


    #
    # init status attribute before Worker object creation
    #
    def init_status
      self.status = :pending
    end
end
