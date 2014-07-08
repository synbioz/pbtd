# == Schema Information
#
# Table name: commits
#
#  id            :integer          not null, primary key
#  deployment_id :integer
#  name          :string(255)
#  sha1          :string(255)
#  user          :string(255)
#  commit_date   :date
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe Commit, :type => :model do
  let(:commit) { Fabricate(:commit) }
  subject { commit }

  # Mandatory attributes

  it { is_expected.to respond_to(:deployment) }
  its(:deployment) { is_expected.to be_kind_of Deployment }

  it { is_expected.to respond_to(:name) }
  its(:name) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:sha1) }
  its(:sha1) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:user) }
  its(:user) { is_expected.to be_instance_of String }

  it { is_expected.to respond_to(:commit_date) }
  its(:commit_date) { is_expected.to be_instance_of Date }

  it { is_expected.to belong_to(:deployment) }

  it 'should have an unique sha1 by commit' do
    c = Fabricate(:commit)
    c.sha1 = subject.sha1
    expect(c).not_to be_valid
  end

  context 'should have sha1 not empty' do
    before { subject.sha1 = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have name not empty' do
    before { subject.name = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have user not empty' do
    before { subject.user = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have commit date not empty' do
    before { subject.commit_date = nil }
    it { expect(subject).not_to be_valid }
  end
end
