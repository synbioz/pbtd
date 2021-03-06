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

  def destroy
    project = Project.find(params[:id])

    project.destroy

    redirect_to root_path
  end

  def update_all_projects
    Project.update_all_locations
    head :ok
  end

  # return head while sidekiq worker for cloning repository not finished. If worker has errors, return them
  # preload_environments check capistrano files of project to find the multiple environments
  def check_environments_preloaded
    @project = Project.find(params[:id])
    if @project.worker.present? && @project.worker.success?
      @project.preload_environments
      render partial: 'edit'
    elsif @project.worker.present? && @project.worker.failure?
      @project.load_errors
      return_response = { errors: @project.errors.full_messages, branches: @project.load_branches }
      @project.destroy
      render json: return_response
    else
      head :ok
    end
  end

  private

    def project_params
      params.require(:project).permit(:name, :repository_url, :default_branch, locations_attributes: [:id, :name, :branch, :application_url])
    end

    def update_project_params
      params.require(:project).permit(:name, locations_attributes: [:id, :name, :branch, :application_url])
    end
end
