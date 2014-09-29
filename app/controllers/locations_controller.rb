class LocationsController < ApplicationController
  respond_to :json

  def destroy
    location = Location.find(params[:id])

    location.destroy

    head :ok
  end

  #
  # Show past deployments
  #
  # @return [void]
  def deployments
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    @deployments = location.deployments.order(updated_at: :desc)

    render partial: 'deployments'
  end

  #
  # Update distance between deployed project and git HEAD branch
  #
  # @return [void]
  def update_distance
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    location.update_distance
    head :ok
  end

  #
  # Launch deploy for specific location
  #
  # @return [void]
  def deploy
    project = Project.find(params[:project_id])
    location = project.locations.find(params[:location_id])
    location.deploy if location.present? && location.distance.present?

    head :ok
  end
end
