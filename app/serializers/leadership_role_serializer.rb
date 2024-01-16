class LeadershipRoleSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  cache key: 'leadership_role', expires_in: 2400.hours
  attributes :id, :name, :title, :headshot, :section, :position

  def headshot
    rails_blob_path(object.headshot, only_path: true) if object.headshot.attached?
  end
end
