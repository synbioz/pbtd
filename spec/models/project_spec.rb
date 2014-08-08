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
  fixtures :all
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

  it { is_expected.to be_valid }

  it 'should have an unique name by project' do
    p = Fabricate(:project)
    p.name = subject.name
    expect(p).not_to be_valid
  end

  it 'should have an unique repository_url' do
    p = Fabricate(:project)
    p.repository_url = subject.repository_url
    expect(p).not_to be_valid
  end

  context 'should not have invalid git repository url' do
    invalid_git = nil
    before do
      invalid_git = subject.dup
      invalid_git.repository_url = 'gitzeft.synbioz.com:synbioz/pbtd.fr'
    end
    it { expect(invalid_git).not_to be_valid }
  end

  context 'should have valid git repository url' do
    before { subject.repository_url = 'git@git.synbioz.com:synbioz/pbtd_test.git' }
    it { expect(subject).to be_valid }
  end

  context 'should have repository_url not empty' do
    invalid_git = nil
    before do
      invalid_git = subject.dup
      invalid_git.repository_url = ''
    end
    it { expect(invalid_git).not_to be_valid }
  end

  describe '#preload_environments' do
    let(:project_deploy) { Fabricate(:project_deploy) }

    context 'with a location' do
      it 'should be array of locations' do
        expect(project_deploy.preload_environments).to eql []
      end
    end
  end
end
