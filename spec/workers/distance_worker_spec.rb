require 'spec_helper'
require 'rails_helper'

describe GitCloneWorker do
  fixtures :all
  let(:invalid_location) { locations(:location_without_project) }
  let(:project) { Fabricate(:project_deploy) }
  let(:worker) { DistanceWorker.new }

  describe '#perform(project.id)' do
    subject { worker.perform(@id) }
    before { allow(worker).to receive(:jid).and_return("352352") }

    context 'invalid job' do
      before { @id = invalid_location.id }

      it 'should be set worker failure' do
        subject
        expect(invalid_location.reload.worker.failure?).to be true
      end
    end

    context 'valid job' do
      let(:location) { project.locations.first }
      before do
        repo = Pbtd::GitRepository.new(project.repository_url)
        repo.clone(project.repo_name, nil)
        project.preload_environments
        @id = location.id
      end

      it 'should be set worker success' do
        subject
        expect(location.reload.worker.success?).to be true
      end
    end
  end
end
