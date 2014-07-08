require 'rails_helper'

RSpec.describe Project, :type => :model do
  let(:project)     { Fabricate(:project) }
  subject { project }

  # Mandatory attributes

  it { is_expected.to respond_to(:name) }
  its(:name) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:repository_url) }
  its(:repository_url) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:environments) }

  it { is_expected.to respond_to(:deployments) }

  it 'has an unique name by project' do
    p = Fabricate(:project)
    p.name = subject.name
    expect(p).not_to be_valid
  end

  context 'have name not empty' do
    before { subject.name = '' }
    it { expect(subject).not_to be_falsey }
  end

  context 'have repository_url not empty' do
    before { subject.repository_url = '' }
    it { expect(subject).not_to be_valid }
  end

  it 'has an unique repository_url' do
    p = Fabricate(:project)
    p.repository_url = subject.repository_url
    expect(p).not_to be_valid
  end
end
