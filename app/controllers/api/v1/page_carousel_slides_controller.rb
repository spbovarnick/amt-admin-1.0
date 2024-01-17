class Api::V1::PageCarouselSlidesController < ApplicationController
    include ActiveStorage::SetCurrent
    include Rails.application.routes.url_helpers

    def index
        if params[:page_title].present?
            page_carousel_slides = PageCarouselSlide.where(:page => params[:page_title]).order(position: :asc)
        else
            page_carousel_slides = PageCarouselSlide.all
        end
        render json: page_carousel_slides
    end
end
