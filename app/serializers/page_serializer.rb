class PageSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'page_data', expires_in: 2400.hours
  attributes :id, :slug, :title, :description, :tag, :header_file, :comm_groups, :ctatext, :ctalink, :subtitle, :donate_url, :collection, :draft, :mail_list_url

  def header_file
    rails_blob_url(object.header_file) if object.header_file.attached?
  end
end

