class Person < ApplicationRecord
  include RevalidatesNextCache

  normalizes :name, with: -> name { name.squish }

  def self.ransackable_attributes(auth_object = nil)
    ["created_by", "name", "updated_by"]
  end
end
