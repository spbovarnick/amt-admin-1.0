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

    if Rails.env.production?
      object.content_files.map { |file| file.url()}
    else
      object.content_files.map { |file| rails_blob_url(file)}
    end

    # object.content_files.map do |file|
    #   if Rails.env.production?
    #     file.url(expires_in: 1.hour, disposition: "inline")
    #   else
    #     rails_blob_url(file)
    #   end
    # end
  end

  def medium_photo_urls
    return [] unless object.medium_photos.attached?

    if Rails.env.production?
      object.medium_photos.map { |photo| photo.url()}
    else
      object.medium_photos.map { |photo| rails_blob_url(photo)}
    end

    # object.medium_photos.map do |photo|
    #   if Rails.env.production?
    #     photo.url(expires_in: 1.hour, disposition: "inline")
    #   else
    #     rails_blob_url(photo)
    #   end
    # end
  end

end
