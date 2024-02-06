class PageSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'page_data', expires_in: 2400.hours
  attributes :id, :title, :description, :tag, :header_file, :comm_groups, :ctatext, :ctalink, :subtitle, :donate_url, :collection, :draft, :mail_list_url

  def header_file
    rails_blob_path(object.header_file , only_path: true) if object.header_file.attached?
  end
end

