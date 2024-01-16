class ArchiveItemSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'archive_item', expires_in: 2400.hours
  attributes :id, :medium, :year, :content_files, :content_urls, :title, :poster_image, :poster_url, :collections, :medium_photos, :medium_photo_urls, :content_notes
  has_many :tags, embed: :id, include: true
  has_many :locations, embed: :id, include: true
  has_many :comm_groups, embed: :id, include: true
  has_many :people, embed: :id, include: true

  def content_files
    content_files = object.content_files.map do |content_file|
      rails_blob_path(content_file , only_path: true) if object.content_files.attached?
    end
  end

  def content_urls
    content_files = object.content_files.map do |content_file|
      content_file.url()
    end
  end

  def medium_photo
    medium_photo = rails_blob_path(object.medium_photo , only_path: true) if object.medium_photo.attached?
  end

  def medium_photo_url
    object.medium_photo.url()
  end

  def medium_photos
    medium_photos = object.medium_photos.map do |medium_photo|
      rails_blob_path(medium_photo , only_path: true) if object.medium_photos.attached?
    end
  end

  def medium_photo_urls
    medium_photos = object.medium_photos.map do |medium_photo|
      medium_photo.url()
    end
  end

  def poster_image
    poster_image = rails_blob_path(object.poster_image , only_path: true) if object.poster_image.attached?
  end

  def poster_url
    object.poster_image.url()
  end
end
