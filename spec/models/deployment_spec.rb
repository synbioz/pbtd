# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  location_id :integer
#  commit_id   :integer
#  status      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Deployment, :type => :model do
  let(:deployment) { Fabricate(:deployment) }
  subject { deployment }

  # Mandatory attributes

  it { is_expected.to respond_to(:location) }
  its(:location) { is_expected.to be_kind_of Location }

  it { is_expected.to respond_to(:status) }
  its(:status) { is_expected.to be_instance_of String }

  it { is_expected.to belong_to(:location) }
  it { is_expected.to belong_to(:commit) }

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

  context 'should have location not empty' do
    before { subject.location = nil }
    it { expect(subject).not_to be_valid }
  end
end
