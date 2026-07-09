class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :lat, :lng, :description
end