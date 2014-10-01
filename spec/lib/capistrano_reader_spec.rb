require 'spec_helper'
require 'rails_helper'

REPOSITORY = "git@github.com:synbioz/pbtd.git"
REPOSITORY_NAME = 'pbtd_capistrano'

describe Pbtd::CapistranoReader do
  before(:all) do
    repo = Pbtd::GitRepository.new(REPOSITORY)
    repo.clone(REPOSITORY_NAME)
    repo.checkout(SETTINGS['default_branch'])
  end

  after(:all) do
    FileUtils.rm_rf(SETTINGS["repositories_path"])
  end

  let(:klass) { Pbtd::CapistranoReader }
  subject { klass.new(REPOSITORY_NAME) }

  describe 'its instance methods' do
    subject { klass.instance_methods }

    it { expect(subject).to include(:environments) }
    it { expect(subject).to include(:version) }
    it { expect(subject).to include(:branch) }
  end

  context '#version' do
    it { expect(subject.version).to be_a String }
  end

  context '#environments' do
    it { expect(subject.environments).to be_an Array }
  end

  context '#branch' do
    let(:branch_name) { subject.environments.first }

    it { expect(subject.branch(branch_name)).to be_a String }
  end

  context '#url' do
    let(:branch_name) { subject.environments.first }

    it { expect(subject.branch(branch_name)).to be_a String }
  end
end
