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

  describe "GET #update_distance" do

    subject { get :update_distance, { project_id: location.project.id, location_id: location.id } }

    it "render head :ok" do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "GET #deploy location" do
    subject { get :deploy, { project_id: location.project.id, location_id: location.id } }

    it 'render header :ok' do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "GET #deployments" do
    subject { get :deployments, { project_id: location.project.id, location_id: location.id } }

    it 'render header :ok' do
      subject
      expect(response.status).to eq 200
    end
  end
end
