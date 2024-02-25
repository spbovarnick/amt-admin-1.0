class CarouselSlidesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_carousel_slide, only: %i[ show edit update destroy ]

  # GET /carousel_slides or /carousel_slides.json
  def index
    @carousel_slides = CarouselSlide.all.order(position: :asc)
  end

  # GET /carousel_slides/1 or /carousel_slides/1.json
  def show
  end

  # GET /carousel_slides/new
  def new
    @pages_options = Page.all.order(title: :asc).pluck(:title, :slug)
    @carousel_slide = CarouselSlide.new
  end

  # GET /carousel_slides/1/edit
  def edit
    @pages_options = Page.all.order(title: :asc).pluck(:title, :slug)
  end

  # POST /carousel_slides or /carousel_slides.json
  def create
    @carousel_slide = CarouselSlide.new(carousel_slide_params)

    respond_to do |format|
      if @carousel_slide.save
        format.html { redirect_to carousel_slides_url, notice: "Carousel slide was successfully created." }
        format.json { render :show, status: :created, location: @carousel_slide }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @carousel_slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carousel_slides/1 or /carousel_slides/1.json
  def update
    respond_to do |format|
      if @carousel_slide.update(carousel_slide_params)
        format.html { redirect_to carousel_slides_url, notice: "Carousel slide was successfully updated." }
        format.json { render :show, status: :ok, location: @carousel_slide }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @carousel_slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carousel_slides/1 or /carousel_slides/1.json
  def destroy
    @carousel_slide.destroy
    respond_to do |format|
      format.html { redirect_to carousel_slides_url, notice: "Carousel slide was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_carousel_slide
      @carousel_slide = CarouselSlide.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def carousel_slide_params
      params.require(:carousel_slide).permit(:title, :description, :link, :image, :position)
    end
end
