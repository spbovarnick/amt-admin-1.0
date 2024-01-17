class LocationsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_location, only: %i[ show edit update destroy ]
  before_action :authorize_archivist

  # GET /locations or /locations.json
  def index
    page_items = params[:page_items].present? ? params[:page_items] : 25

    if params[:archive_q]
      @pagy, @locations = pagy(Location.ransack(name_cont: params[:archive_q]).result, page: params[:page], items: page_items)
    else
      @pagy, @locations = pagy(Location.all.order(name: :asc), page: params[:page], items: page_items)
    end
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @current_user = current_admin_user
  end

  # GET /locations/1/edit
  def edit
    @current_user = current_admin_user
  end

  # POST /locations or /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to admin_locations_path, notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    old_name = @location.name

    respond_to do |format|
      if @location.update(location_params)
        # this iterator updates search strings of all archive item instances tagged with this @location, necessary bc acts_as_ordered_taggable_on abstracts archive item instances from location instances
        ArchiveItem.tagged_with(old_name, :on => :locations).each do |item|
          item.location_list.remove(old_name)
          item.location_list.add(@location.name)
          item.update_columns(search_locations: item.location_list.join(', '))
          item.save
        end
        format.html { redirect_to admin_locations_path, notice: "Location was successfully updated." }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to admin_locations_url, notice: "Location was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.require(:location).permit(:name, :lat, :lng, :description, :created_by, :updated_by)
    end
end
