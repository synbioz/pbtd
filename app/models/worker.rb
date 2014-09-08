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

  enum status: [ :pending, :running, :success, :failure ]

  validates :job_id, presence: true
  validates :class_name, presence: true

  # Go to the failure status and update the error_class_name
  # and error_message fields with the informations in the given
  # Exception.
  #
  # @param [Exception] 
  def fail_with!(exception)
    self.error_class_name = exception.class.name
    self.error_message = exception.message
    failure!
  end
end
