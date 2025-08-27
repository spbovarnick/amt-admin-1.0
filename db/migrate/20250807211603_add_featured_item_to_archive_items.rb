class AddFeaturedItemToArchiveItems < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :featured_item, :boolean
  end
end
