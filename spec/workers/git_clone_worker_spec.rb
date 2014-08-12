require 'spec_helper'
require 'rails_helper'

describe GitCloneWorker do
  let(:project) { Fabricate(:project_deploy) }
  let(:invalid_project) { Fabricate(:invalid_project_deploy) }
  let(:worker) { GitCloneWorker.new }

  describe '#perform(project.id)' do
    subject { worker.perform(@id) }
    before { allow(worker).to receive(:jid).and_return("352352") }

    context 'valid job' do
      before { @id = project.id }

      it 'should be set worker success' do
        subject
        expect(project.reload.worker.success?).to be true
      end
    end

    context 'invalid job' do
      before { @id = invalid_project.id }

      it 'should be set worker failure' do
        subject
        expect(invalid_project.reload.worker.failure?).to be true
      end
    end
  end
end
