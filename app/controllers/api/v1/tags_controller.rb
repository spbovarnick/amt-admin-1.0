class Api::V1::TagsController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    Rails.logger.info("TagsController#index hit")
    tags = ArchiveTag.all.order(name: :asc)
    Rails.logger.info( "All tags: #{tags.pluck(:name).inspect}")
    render json: tags
  end
end
