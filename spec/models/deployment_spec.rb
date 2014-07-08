# == Schema Information
#
# Table name: deployments
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  location_id :integer
#  state       :string(255)
#  finish_at   :date
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Deployment, :type => :model do
  let(:deployment) { Fabricate(:deployment) }
  subject { deployment }

  # Mandatory attributes

  it { is_expected.to respond_to(:project) }
  its(:project) { is_expected.to be_kind_of Project }

  it { is_expected.to respond_to(:location) }
  its(:location) { is_expected.to be_kind_of Location }

  it { is_expected.to respond_to(:state) }
  its(:state) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:finish_at) }
  its(:finish_at) { is_expected.to be_instance_of Date }

  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:location) }

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

  context 'should have pending status' do
    before { subject.pending! }
    it { expect(subject.pending?).to be true }
  end

  context 'should have project not empty' do
    before { subject.project = nil }
    it { expect(subject).not_to be_valid }
  end

  context 'should have location not empty' do
    before { subject.location = nil }
    it { expect(subject).not_to be_valid }
  end

  context 'should have finish_at not empty' do
    before { subject.finish_at = nil }
    it { expect(subject).not_to be_valid }
  end
end
