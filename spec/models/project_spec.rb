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
    p = Project.new(repository_url: subject.repository_url)

    expect(p).not_to be_valid
  end

  context 'should not have invalid git repository url' do
    invalid_git = nil
    before do
      invalid_git = subject.dup
      invalid_git.repository_url = 'gitfaef.github.com:synbioz/pbtd.git'
    end
    it { expect(invalid_git).not_to be_valid }
  end

  context 'should have valid git repository url' do
    before { subject.repository_url = 'git@github.com:synbioz/pbtd.git' }
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

    context 'with no locations' do
      it 'should be nil array' do
        expect(project.preload_environments).to eq []
      end
    end

    context 'with locations' do
      before do
        project.repository_url = "git@github.com:synbioz/pbtd.git"
        repo = Pbtd::GitRepository.new(project.repository_url)
        repo.clone(project.repo_name, nil)
      end

      it 'should be array of locations' do
        expect(project.preload_environments).to include "staging"
      end
    end
  end

  describe '#load_errors' do

    context 'without errors' do
      before do
        project.worker = workers(:worker_1)
        project.load_errors
      end

      it 'should have no errors' do
        expect(project.errors.full_messages).to eq []
      end
    end

    context 'with errors' do
      before do
        project.worker = workers(:worker_3)
        project.load_errors
      end

      it 'should add errors to project' do
        expect(project.errors.full_messages.to_s).to include project.worker.error_message
      end
    end
  end

  describe '#load_branches' do

    context 'project with branches' do

      it 'should return branches' do
        expect(project.load_branches).to eq ["origin/develop"]
      end
    end

    context 'project without branches' do
      it 'should return nil array' do
        expect(project.load_branches).to be_nil
      end
    end
  end

  describe '#update_locations_distance' do

    context 'project without locations' do
      it 'should return nil array' do
        expect(project.update_locations_distance).to eql []
      end
    end

    context 'project with location' do
      before do
        project.preload_environments
      end

      it 'should change location distance' do
        project.locations << Location.new(name: "staging", branch: "develop", application_url: "http://pbtd.domain.tld")
        expect(project.update_locations_distance).to include project.locations.first
      end
    end
  end

  describe '.update_all_locations' do

    context 'with projects' do
      it { expect(Project.update_all_locations).to include project.locations }
    end
  end

  describe 'private #cloning_repository' do

    context 'with nil worker' do
      it { expect(project.send(:cloning_repository)).to be_a String }
    end

    context 'failure worker' do
      before { project.worker = workers(:worker_3) }

      it { expect(project.send(:cloning_repository)).to be_a String }
    end

    context 'with worker success' do
      before { project.worker = workers(:worker_1) }

      it { expect(project.send(:cloning_repository)).to be_nil }
    end
  end

  describe 'private #rm_physic_folder' do

    it 'should remove repository folder' do
      project_path = File.join(SETTINGS["repositories_path"], project.repo_name)
      project.send(:rm_physic_folder)
      expect(Dir.exists?(project_path)).to be false
    end
  end
end
