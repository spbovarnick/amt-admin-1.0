class ArchiveTag < ApplicationRecord

  # ransack requires ransackable attributes be required. this is a boiler plate method 
  def self.ransackable_attributes(auth_object = nil)
    ["created_by", "name", "updated_by"]
  end
end
