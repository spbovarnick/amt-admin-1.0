class Person < ApplicationRecord
  include RevalidatesNextCache

  def self.ransackable_attributes(auth_object = nil)
    ["created_by", "name", "updated_by"]
  end
end
