require 'rails_helper'

RSpec.describe LocationsController, :type => :controller do
  fixtures :all
  let(:location) { Fabricate(:location) }

  describe "delete #destroy" do
      subject { delete :destroy, project_id: location.project.id, id: location.id }

      it 'render head :ok' do
        subject
        expect(response.status).to eq 200
      end
    end
end
