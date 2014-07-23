require 'rails_helper'

RSpec.describe ProjectsController, :type => :controller do

  context "with an existing valid project" do
    fixtures :projects
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
        expect(assigns(:project)).to be_a_new(Project)
      end
    end

    describe "POST #create" do
      subject { post :create, @params }

      context "with valid project" do
        before { @params = { project: Fabricate.attributes_for(:valid_project) } }

        it "renders the create template" do
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
  end
end
