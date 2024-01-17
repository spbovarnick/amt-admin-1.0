class Api::V1::CommGroupsController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    groups = CommGroup.all.order(name: :asc)
    render json: groups
  end
end
