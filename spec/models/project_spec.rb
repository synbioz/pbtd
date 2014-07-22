# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  repository_url :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  worker_id      :integer
#

require 'rails_helper'

RSpec.describe Project, :type => :model do
  let(:project) { Fabricate(:project) }
  subject { project }

  # Mandatory attributes

  it { is_expected.to respond_to(:name) }
  its(:name) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:repository_url) }
  its(:repository_url) { is_expected.to be_an_instance_of String }

  it { is_expected.to respond_to(:locations) }
  it { is_expected.to have_many(:locations).class_name('Location') }

  it { is_expected.to belong_to(:worker) }

  it 'should have an unique name by project' do
    p = Fabricate(:project)
    p.name = subject.name
    expect(p).not_to be_valid
  end

  context 'should have name not empty' do
    before { subject.name = '' }
    it { expect(subject).not_to be_valid }
  end

  context 'should not have invalid git repository url' do
    before { subject.repository_url = 'gitzeft.synbioz.com:synbioz/pbtd.fr' }
    it { expect(subject).not_to be_valid }
  end

  context 'should have valid git repository url' do
    before { subject.repository_url = 'git@git.synbioz.com:synbioz/pbtd.git' }
    it { expect(subject).to be_valid }
  end

  context 'should have repository_url not empty' do
    before { subject.repository_url = '' }
    it { expect(subject).not_to be_valid }
  end

  it 'should have an unique repository_url' do
    p = Fabricate(:project)
    p.repository_url = subject.repository_url
    expect(p).not_to be_valid
  end
end
