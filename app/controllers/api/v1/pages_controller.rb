class Api::V1::PagesController < ApplicationController
  include ActiveStorage::SetCurrent
  include Rails.application.routes.url_helpers
  def index
    pages = Page.all.order(created_at: :desc)
    render json: pages
  end

  def show
    if page
      render json: page
    else
      render json: page.errors
    end
  end

  private

  def page
    @page ||= Page.find_by(slug: params[:slug])
  end
end
