require 'spec_helper'
require 'rails_helper'
require 'rugged'

GIT_REPOSITORY = "git@github.com:synbioz/pbtd.git"
GIT_REPOSITORY_NAME = 'pbtd'

describe Pbtd::GitRepository do
  after(:all) do
    FileUtils.rm_rf(SETTINGS["repositories_path"])
  end

  let(:klass) { Pbtd::GitRepository }
  subject     { klass.new }

  describe 'its instance methods' do
    subject { klass.instance_methods }

    it { expect(subject).to include(:open) }
    it { expect(subject).to include(:clone) }
    it { expect(subject).to include(:remote_branches) }
    it { expect(subject).to include(:last_commit) }
    it { expect(subject).to include(:fetch) }
    it { expect(subject).to include(:get_behind) }
    it { expect(subject).to include(:merge) }
  end

  context 'can clone git repository' do
    subject { klass.new(GIT_REPOSITORY) }

    it '#clone' do
      subject.clone(GIT_REPOSITORY_NAME)
      expect(klass.exist?(GIT_REPOSITORY_NAME)).to be true
    end
  end

  context 'can access to local repository' do
    subject { klass.new }
    before { subject.open(GIT_REPOSITORY_NAME) }

    it '#open' do
      response = subject.open(GIT_REPOSITORY_NAME)
      expect(response).to be_instance_of(Rugged::Repository)
    end

    it '#remote_branches' do
      expect(subject.remote_branches).to be_an(Array)
    end

    it '#fetch' do
      expect(subject.fetch).to be_a Integer
    end
  end

  context 'access to branch' do
    before { subject.open(GIT_REPOSITORY_NAME) }

    let(:first_branch) { subject.remote_branches.first }

    it '#last_commit' do
      expect(subject.last_commit(first_branch)).to be_instance_of(Rugged::Commit)
    end

    it '#get_behind' do
      expect(subject.get_behind(first_branch, '1941737')).to be_a Integer
    end

    it '#merge' do
      expect(subject.merge(first_branch)).to be_instance_of(Rugged::Reference)
    end
  end

  context 'switch branch' do
    before { subject.open(GIT_REPOSITORY_NAME) }

    let(:branch) { subject.remote_branches.first }

    it '#checkout' do
      expect(subject.checkout(branch)).to be_instance_of(Rugged::Reference)
    end
  end

  context 'branch local -> remote' do
    before { subject.open(GIT_REPOSITORY_NAME) }

    it '#remote_branch_from_local' do
      local_branch = 'develop'
      expect(subject.remote_branch_from_local(local_branch)).to eq('origin/develop')
    end
  end
end
