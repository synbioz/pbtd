require 'rails_helper'

RSpec.describe ProjectsController, :type => :controller do

  context "with an existing valid project" do
    fixtures :all
    let(:project) { projects(:project_1) }

    describe "GET #index" do
      render_views
      subject { get :index }

      it { is_expected.to be_success }

      it "renders the index template" do
        subject
        expect(response).to render_template :index
      end

      it "populates @projects && @project" do
        subject
        expect(assigns(:projects)).to match_array(Project.all)
        expect(project).to be_instance_of(Project)
      end
    end

    describe "POST #create" do
      subject { post :create, @params }

      context "with valid project" do
        before { @params = { project: Fabricate.attributes_for(:valid_project) } }

        it "renders the project partial template" do
          subject
          expect(response).to render_template(partial: '_project')
        end

        it "creates new project" do
          expect{subject}.to change(Project, :count).by(1)
        end
      end

      context "with invalid repository_url" do
        before { @params = { project: Fabricate.attributes_for(:invalid_project) } }

        it "renders json errors" do
          subject
          expect(response.body).to eq ["Repository url n'est pas valide"].to_json
        end
      end
    end

    describe "PUT #update" do
      subject { put :update, @params }

      context "with valid update for project" do
        let(:valid_project) { Fabricate.build(:valid_project) }
        before do
          @params = { id: project.id, project: Fabricate.attributes_for(:valid_project) }
        end

        it "renders the project partial template" do
          subject
          expect(response).to render_template(partial: '_project')
        end

        it "update project" do
          subject
          project.reload
          expect(project.name).to eq valid_project.name
        end
      end

      context "with invalid update for project" do
        before do
          @params = { id: project.id, project: Fabricate.attributes_for(:invalid_project) }
        end

        it "not update project" do
          expect{subject}.not_to change(project, :repository_url)
        end
      end
    end

    describe "GET #check_environments_preloaded" do
      render_views
      subject { get :check_environments_preloaded, id: project.id }

      it { is_expected.to be_success }

      context "with worker present && worker success status" do

        it "render the edit partial template" do
          subject
          expect(response).to render_template(partial: '_edit')
        end

        it "preload locations for project" do
          subject
          expect(project.locations).to match_array(Location.where(project_id: project.id))
        end
      end
    end
  end
end
