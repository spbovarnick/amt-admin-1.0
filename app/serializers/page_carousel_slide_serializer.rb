class PageCarouselSlideSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'page_carousel_slide', expires_in: 2400.hours
  attributes :id, :title, :description, :collections, :page, :image, :image_url, :year, :comm_groups, :medium, :people, :locations, :tags

  def tags
    object.tags.present? ? object.tags.split(', ') : nil
  end

  def locations
    object.locations.present? ? object.locations.split(', ') : nil
  end

  def people
    object.people.present? ? object.people.split(', ') : nil
  end

  def collections
    object.collections.present? ? object.collections.split(', ') : nil
  end

  def comm_groups
    object.comm_groups.present? ? object.comm_groups.split(', ') : nil
  end

  def image
    rails_blob_url(object.image) if object.image.attached?
  end

  def image_url
    object.image.url()
  end
end
