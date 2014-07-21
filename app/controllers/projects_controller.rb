class ProjectsController < ApplicationController

  def index
    @project = Project.new
    @projects = Project.all
  end

  def create
    project = Project.new(project_params)

    if project.save
      render project
    else
      render json: project.errors.full_messages
    end
  end

  def edit
    @project = Project.find(params[:id])

    render partial: 'edit'
  end

  def update
    project = Project.find(params[:id])
    if project.update_attributes(project_params)
      render project
    else
      render json: project.errors.full_messages
    end
  end

  def check_environments_preloaded
    project = Project.find(params[:id])
    if !project.worker.nil? && project.worker.success?
      locations = project.preload_environments
      render partial: 'edit', locals: {project: project, locations: locations}
    else
      render nothing: true
    end
  end

  private

    def project_params
      params.require(:project).permit(:name, :repository_url, locations_attributes: [:id, :name, :branch, :application_url])
    end
end
