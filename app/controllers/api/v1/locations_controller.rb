class Api::V1::LocationsController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    locations = Location.all.order(name: :asc)
    render json: locations
  end

  def show
    if location
      render json: location
    else
      render json: location.errors
    end
  end

  private

  def location
    # location instances are accessed by name rather than id, bc the id returned to archive_items is the acts_as_taggable id rather than the actual active record id
    @location ||= Location.where(:name => params[:name])
  end
end
