class Location < ApplicationRecord
  include RevalidatesNextCache

  # Unanchored so they can be reused as HTML `pattern` attributes (which anchor implicitly)
  LAT_PATTERN = '-?(?:90(?:\.0+)?|[1-8]?\d(?:\.\d+)?)'
  LNG_PATTERN = '-?(?:180(?:\.0+)?|(?:1[0-7]\d|[1-9]?\d)(?:\.\d+)?)'

  normalizes :name, with: -> name { name.squish }
  normalizes :lat, :lng, with: -> coord { coord.strip.delete_suffix(",").strip }

  validates :lat, format: { with: /\A#{LAT_PATTERN}\z/, message: "must be a decimal between -90 and 90" }, allow_blank: true
  validates :lng, format: { with: /\A#{LNG_PATTERN}\z/, message: "must be a decimal between -180 and 180" }, allow_blank: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_by", "description", "lat", "lng", "name", "updated_by"]
  end
end
