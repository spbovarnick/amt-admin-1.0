class Collection < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
  ["created_by", "name", "updated_by"]
  end

  def id_and_name
    "#{id}_#{name}"
  end
end
