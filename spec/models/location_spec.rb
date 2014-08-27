# == Schema Information
#
# Table name: locations
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  name            :string(255)
#  branch          :string(255)
#  application_url :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  distance        :integer
#  worker_id       :integer
#

require 'rails_helper'

RSpec.describe Location, :type => :model do
  let(:location) { Fabricate(:location) }
  subject { location }

  # Mandatory attributes

  it { is_expected.to respond_to(:name) }
  its(:name) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:project_id) }
  its(:project) { is_expected.to be_kind_of Project }

  it { is_expected.to respond_to(:worker) }
  its(:worker) { is_expected.to be_kind_of Worker }

  it { is_expected.to respond_to(:branch) }
  its(:branch) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:application_url) }
  its(:application_url) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:distance) }
  its(:distance) { is_expected.to be_an Integer }

  it { is_expected.to have_many(:commits).class_name('Commit') }
  it { is_expected.to have_many(:deployments).class_name('Deployment') }

  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:worker) }

  context 'should have a name' do
    before { subject.name = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have a branch' do
    before { subject.branch = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have an application_url' do
    before { subject.application_url = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have a project' do
    before { subject.project = nil }
    it { expect(subject).not_to be_valid }
  end

  describe '#deploy' do
    it { expect(location.deploy).to be_a String }
  end

  describe '#get_current_release_commit' do

    context 'with incorrect location' do
      it { expect{ location.get_current_release_commit }.to raise_error(Pbtd::Error::FileNotFound) }
    end
  end
end
