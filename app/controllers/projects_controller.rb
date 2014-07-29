class ProjectsController < ApplicationController
  include ActionController::Live
  respond_to :json

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

  def update_all_projects
    Project.update_all_locations

    render nothing: true
  end

  def update_project_location
    project = Project.find(params[:id])
    location = project.locations.find(params[:location_id])
    location.update_distance
    redirect_to root_path
  end

  def check_updates
    response.headers['Content-Type'] = 'text/event-stream'

    begin
      Location.uncached do
        locations = Location.all.to_a
        for location in locations
          location.worker = nil
          while not location.worker.present? && (location.worker.success? || location.worker.failure?)
            sleep 1
            response.stream.write "data: loading\n\n"
            location.reload
          end
          if location.worker.success?
            informations = { location_id: location.id, distance: location.distance }
            response.stream.write "data: #{informations.to_json}\n\n"
          end
        end
      end
    rescue IOError
    ensure
      response.stream.close
    end
  end

  def check_environments_preloaded
    project = Project.find(params[:id])
    if project.worker.present? && project.worker.success?
      project.preload_environments
      render partial: 'edit', locals: { project: project }
    elsif project.worker.present? && project.worker.failure?
      project.load_errors
      render json: project.errors.full_messages
    else
      render nothing: true
    end
  end

  def deploy_location
    location = Location.find(params[:location_id])

    unless location.nil?
      location.deploy
    end

    redirect_to root_path
  end

  private

    def project_params
      params.require(:project).permit(:name, :repository_url, locations_attributes: [:id, :name, :branch, :application_url])
    end
end
