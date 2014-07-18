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

require 'rails_helper'

RSpec.describe Worker, :type => :model do
  let(:worker) { Fabricate(:worker) }
  subject { worker }

  # Mandatory attributes
  it { is_expected.to respond_to(:job_id) }
  its(:job_id) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:class_name) }
  its(:class_name) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:status) }
  its(:status) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:error_class_name) }
  its(:error_class_name) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:error_message) }
  its(:error_message) { is_expected.to be_instance_of String }

  describe 'should not empty' do
    context 'job_id' do
      before { subject.job_id = '' }
      it { expect(subject).not_to be_valid }
    end

    context 'class_name' do
      before { subject.class_name = '' }
      it { expect(subject).not_to be_valid }
    end
  end

  describe 'should have correct status' do
    context 'should have running status' do
      before { subject.running! }
      it { expect(subject.running?).to be true }
    end

    context 'should have failure status' do
      before { subject.failure! }
      it { expect(subject.failure?).to be true }
    end

    context 'should have success status' do
      before { subject.success! }
      it { expect(subject.success?).to be true }
    end

    context 'pending' do
      before { subject.pending! }
      it { expect(subject.pending?).to be true }
    end
  end
end
