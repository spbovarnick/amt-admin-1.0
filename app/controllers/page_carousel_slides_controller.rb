class PageCarouselSlidesController < ApplicationController
  layout 'admin', except: [:display]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :set_page_carousel_slide, only: %i[ show edit update destroy ]
  before_action :authorize_archivist

  # GET /page_carousel_slides or /page_carousel_slides.json
  def index
    if current_user.page == "global"
      @page_carousel_slides = PageCarouselSlide.all.order(page: :asc, position: :asc)
    else
      @page_carousel_slides = PageCarouselSlide.where(:page => current_user.page).order(position: :asc)
    end
  end

  # GET /page_carousel_slides/1 or /page_carousel_slides/1.json
  def show
  end

  # GET /page_carousel_slides/new
  def new
    @current_user = current_user
    @collections_options = Collection.all.order(name: :desc).pluck(:name)
    @year_options = {
      "Any" => "",
      "1940's" => 1940,
      "1950's" => 1950,
      "1960's" => 1960,
      "1970's" => 1970,
      "1980's" => 1980,
      "1990's" => 1990,
      "2000's" => 2000,
      "2010's" => 2010,
      "2020's" => 2020
    }
    @medium_options = {
      "Any" => "",
      "Photos" => "photo",
      "Films" => "film",
      "Audio" => "audio",
      "Articles" => "article",
      "Printed Material" => "printed material"
    }
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @people_options = Person.all.order(name: :desc).pluck(:name)
    @location_options = Location.all.order(name: :desc).pluck(:name)
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @page_options = Page.all.order(title: :desc).pluck(:title)
    @page_carousel_slide = PageCarouselSlide.new
  end

  # GET /page_carousel_slides/1/edit
  def edit
    @current_user = current_user
    @collections_options = Collection.all.order(name: :desc).pluck(:name)
    @year_options = {
      "Any" => "",
      "1940's" => 1940,
      "1950's" => 1950,
      "1960's" => 1960,
      "1970's" => 1970,
      "1980's" => 1980,
      "1990's" => 1990,
      "2000's" => 2000,
      "2010's" => 2010,
      "2020's" => 2020
    }
    @medium_options = {
      "Any" => "",
      "Photos" => "photo",
      "Films" => "film",
      "Audio" => "audio",
      "Articles" => "article",
      "Printed Material" => "printed material"
    }
    @comm_group_options = CommGroup.all.order(name: :desc).pluck(:name)
    @people_options = Person.all.order(name: :desc).pluck(:name)
    @location_options = Location.all.order(name: :desc).pluck(:name)
    @tag_options = ArchiveTag.all.order(name: :desc).pluck(:name)
    @page_options = Page.all.order(title: :desc).pluck(:title)
    @page_carousel_slide = PageCarouselSlide.find(params[:id])
  end

  # POST /page_carousel_slides or /page_carousel_slides.json
  def create
    @page_carousel_slide = PageCarouselSlide.new(page_carousel_slide_params)

    respond_to do |format|
      if @page_carousel_slide.save
        format.html { redirect_to page_carousel_slides_path, notice: "Page carousel slide was successfully created." }
        format.json { render :show, status: :created, location: @page_carousel_slide }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page_carousel_slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_carousel_slides/1 or /page_carousel_slides/1.json
  def update
    respond_to do |format|
      if @page_carousel_slide.update(page_carousel_slide_params)
        format.html { redirect_to page_carousel_slides_path, notice: "Page carousel slide was successfully updated." }
        format.json { render :show, status: :ok, location: @page_carousel_slide }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page_carousel_slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_carousel_slides/1 or /page_carousel_slides/1.json
  def destroy
    @page_carousel_slide.destroy
    respond_to do |format|
      format.html { redirect_to page_carousel_slides_url, notice: "Page carousel slide was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_carousel_slide
      @page_carousel_slide = PageCarouselSlide.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def page_carousel_slide_params
      params.require(:page_carousel_slide).permit(:title, :description, :collections, :year, :page, :image, :position, :comm_groups, :medium, :people, :locations, :tags)
    end
end
