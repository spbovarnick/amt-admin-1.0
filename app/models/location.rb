class Location < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["created_by", "description", "lat", "lng", "name", "updated_by"]
  end
end
