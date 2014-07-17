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

  private

    def project_params
      params.require(:project).permit(:name, :repository_url)
    end
end
