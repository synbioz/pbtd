require 'spec_helper'
require 'rails_helper'

describe GitCloneWorker do
  fixtures :all
  let(:location) { locations(:locations_6) }
  let(:worker) { DistanceWorker.new }

  describe '#perform(project.id)' do
    subject { worker.perform(@id) }
    before { allow(worker).to receive(:jid).and_return("352352") }

    context 'invalid job' do
      before { @id = location.id }

      it 'should be set worker failure' do
        subject
        expect(location.reload.worker.failure?).to be true
      end
    end
  end
end
