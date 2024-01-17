class Api::V1::NewsItemsController < ApplicationController
    include ActiveStorage::SetCurrent
    def index
        stories = NewsItem.all.order(created_at: :desc).limit(2)
        render json: stories
    end
end