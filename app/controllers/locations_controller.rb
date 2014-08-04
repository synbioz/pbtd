class LocationsController < ApplicationController
  respond_to :json

  def destroy
    location = Location.find(params[:id])

    location.destroy

    head :ok
  end
end
