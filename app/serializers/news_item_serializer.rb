class NewsItemSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :headline, :author, :body, :created_by, :updated_by, :photo, :cta_text, :cta_link

  def photo
    photo = rails_blob_path(object.photo , only_path: true) if object.photo.attached?
  end
end
