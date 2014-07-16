require 'spec_helper'

describe Pbtd::Capistrano::Reader do

  let(:klass) { Pbtd::Capistrano::Reader }
  subject { klass.new('article-ehstore') }

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
end
