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
  validates :status, presence: true
  validates :error_class_name, presence: true
  validates :error_message, presence: true
end
