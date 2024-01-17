class Api::V1::CollectionsController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    collections = Collection.all.order(name: :asc)
    render json: collections
  end
end