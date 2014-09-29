class LocationsController < ApplicationController
  respond_to :json

  def destroy
    location = Location.find(params[:id])

    location.destroy

    head :ok
  end

  def deployments
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    @deployments = location.deployments.order(updated_at: :desc)

    render partial: 'deployments'
  end

  def update_distance
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    location.update_distance
    head :ok
  end

  def deploy
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    location.deploy if location.present? && location.distance.present?

    head :ok
  end
end
