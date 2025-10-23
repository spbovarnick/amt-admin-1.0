require 'open-uri'

class RedirectLink < ApplicationRecord
  belongs_to :archive_item, inverse_of: :redirect_links, foreign_key: :archive_item_id

  validates :url_label, presence: false, length: { maximum: 300 }
  validates :url, presence: false, length: { maximum: 2048 }
  validate :url_is_valid

  before_validation :strip_whitespace

  private

  def strip_whitespace
    self.url_label = url_label&.strip
    self.url = url&.strip
  end

  def url_is_valid
    return if url.blank?
    begin
      URI.open(url).status
    rescue
      errors.add(:url, "is not a valid URL")
    end
  end
end