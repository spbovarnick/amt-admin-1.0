class CarouselSlideSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'carousel_slide', expires_in: 2400.hours
  attributes :id, :title, :description, :link, :image, :image_url

  def image
    image = rails_blob_url(object.image) if object.image.attached?
  end

  def image_url
    return nil unless object.image.attached?

    if Rails.env.production?
      object.image.url()
    else
      rails_blob_url(object.image)
    end
  end
end
