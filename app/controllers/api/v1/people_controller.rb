class Api::V1::PeopleController < ApplicationController
  include ActiveStorage::SetCurrent
  def index
    people = Person.all.order(name: :asc)
    render json: people
  end
end
