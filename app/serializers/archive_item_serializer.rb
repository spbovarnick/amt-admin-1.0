class ArchiveItemSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :medium, :year, :title, :content_notes, :credit, :draft, :poster_url, :content_file_urls, :content_file_names, :medium_photo_urls, :medium_photos_file_names, :collections, :credit, :featured_item
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

  def content_file_names
    return [] unless object.content_files.attached?

    object.ordered_content_files.map { |file| file.filename.to_s }
  end

  def content_file_urls
    return [] unless object.content_files.attached?

    if Rails.env.production?
      object.ordered_content_files.map { |file| file.url()}
    else
      object.ordered_content_files.map { |file| rails_blob_url(file)}
    end
  end

  def medium_photo_urls
    return [] unless object.medium_photos.attached?

    if Rails.env.production?
      object.medium_photos.map { |photo| photo.url()}
    else
      object.medium_photos.map { |photo| rails_blob_url(photo)}
    end
  end

  def medium_photos_file_names
    return [] unless object.medium_photos.attached?

    object.medium_photos.map { |file| file.filename.to_s }
  end

end
