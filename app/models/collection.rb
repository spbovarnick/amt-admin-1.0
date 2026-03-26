class Collection < ApplicationRecord
  include RevalidatesNextCache

  normalizes :name, with: -> name { name.squish }

  def self.ransackable_attributes(auth_object = nil)
  ["created_by", "name", "updated_by"]
  end

  # special concatenation for instantiation UID and UID UI in ArchiveItem#new
  def id_and_name
    "#{id}_#{name}"
  end
end
