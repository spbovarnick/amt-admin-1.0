class Api::V1::LeadershipRolesController < ApplicationController
    include ActiveStorage::SetCurrent
    include Rails.application.routes.url_helpers
    def index
        roles = LeadershipRole.all.order(created_at: :desc)
        render json: roles
    end

    def board
        roles = LeadershipRole.where(:section => "board").order(position: :asc)
        render json: roles
    end

    def staff
        roles = LeadershipRole.where(:section => "staff").order(position: :asc)
        render json: roles
    end
end