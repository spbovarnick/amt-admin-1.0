class ArchiveItemSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :medium, :year, :title, :content_notes, :credit, :draft, :poster_url, :content_file_urls, :medium_photo_urls, :collections, :credit
  has_many :tags, embed: :id, include: true
  has_many :locations, embed: :id, include: true
  has_many :comm_groups, embed: :id, include: true
  has_many :people, embed: :id, include: true

  def poster_url
    return nil unless object.poster_image.attached?

    if Rails.env.production?
      object.poster_image.url()
    else
      rails_blob_url(object.poster_image)
    end
  end

  def content_file_urls
    return [] unless object.content_files.attached?

    object.content_files.map do |file|
      if Rails.env.production?
        file.url()
      else
        rails_blob_url(file)
      end
    end
  end

  def medium_photo_urls
    return [] unless object.medium_photos.attached?

    object.medium_photos.map do |photo|
      if Rails.env.production?
        photo.url()
      else
        rails_blob_url(photo)
      end
    end
  end

end
