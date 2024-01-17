class Api::V1::CarouselSlidesController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    slides = CarouselSlide.all.order(position: :asc)
    render json: slides
  end
end
