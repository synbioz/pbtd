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

    describe "GET #new" do
      render_views
      subject { get :new }

      it { is_expected.to be_success }

      it "render the template 'new'" do
        subject
        expect(response).to render_template(partial: '_new')
      end

      it "build @project" do
        subject
        expect(project).to be_instance_of Project
      end
    end

    describe "Get #edit" do
      render_views
      subject { get :edit, id: project.id }

      it { is_expected.to be_success }

      it "render the template 'edit'" do
        subject
        expect(response).to render_template(partial: '_edit')
      end

      it "find @project" do
        subject
        expect(project).to be_instance_of Project
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
          expect(response.body).to eq ["Repository url is invalid"].to_json
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

        it "render json errors" do
          subject
          expect(response.body).to eq ["Name can't be blank"].to_json
        end
      end
    end

    describe "GET #update_all_projects" do
      subject { get :update_all_projects }

      it "render head :ok" do
        subject
        expect(response.status).to eq 200
      end
    end

    describe "GET #update_project_location" do
      let(:location_id) { project.locations.first.id }

      subject { get :update_project_location, { id: project.id, location_id: location_id } }

      it "render head :ok" do
        subject
        expect(response.status).to eq 200
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

      context "with worker failure" do
        before { project.worker.failure! }

        it 'should return json errors' do
          subject
          expect(response.body).to include 'errors'
        end
      end

      context "with worker not present" do
        before { project.worker.delete }
        it 'should return head :ok' do
          subject
          expect(response.status).to eq 200
        end
      end
    end

    describe "GET #deploy location" do
      subject { get :deploy_location, id: project.id, location_id: project.locations.first.id }

      it 'render header :ok' do
        subject
        expect(response.status).to eq 200
      end
    end

    describe "delete #destroy" do
      subject { delete :destroy, id: project.id }

      it 'redirect to root_path' do
        expect(subject).to redirect_to('/')
      end
    end
  end
end
