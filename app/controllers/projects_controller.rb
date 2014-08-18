class ProjectsController < ApplicationController
  respond_to :json

  def index
    @projects = Project.all.order(:created_at)
  end

  def create
    project = Project.new(project_params)
    if project.save
      render project
    else
      render json: project.errors.full_messages
    end
  end

  def new
    @project = Project.new
    render partial: 'new'
  end

  def edit
    @project = Project.find(params[:id])

    render partial: 'edit'
  end

  def update
    project = Project.find(params[:id])
    if project.update_attributes(update_project_params)
      render project
    else
      render json: project.errors.full_messages
    end
  end

  def update_all_projects
    Project.update_all_locations
    head :ok
  end

  def update_project_location
    project = Project.find(params[:id])
    location = project.locations.find(params[:location_id])
    location.update_distance
    head :ok
  end

  def check_environments_preloaded
    project = Project.find(params[:id])
    if project.worker.present? && project.worker.success?
      project.preload_environments
      render partial: 'edit', locals: { project: project }
    elsif project.worker.present? && project.worker.failure?
      project.load_errors
      return_response = { errors: project.errors.full_messages, branches: project.load_branches }
      project.destroy
      render json: return_response
    else
      head :ok
    end
  end

  def deploy_location
    project = Project.find(params[:id])
    location = project.locations.find(params[:location_id])
    location.deploy unless location.nil?

    head :ok
  end

  def deployments
    project = Project.find(params[:id])
    location = project.locations.find(params[:location_id])
    @deployments = location.deployments.order(updated_at: :desc)

    render partial: 'deployments'
  end

  def destroy
    project = Project.find(params[:id])

    project.destroy

    redirect_to root_path
  end

  private

    def project_params
      params.require(:project).permit(:name, :repository_url, :default_branch, locations_attributes: [:id, :name, :branch, :application_url])
    end

    def update_project_params
      params.require(:project).permit(:name, locations_attributes: [:id, :name, :branch, :application_url])
    end
end
