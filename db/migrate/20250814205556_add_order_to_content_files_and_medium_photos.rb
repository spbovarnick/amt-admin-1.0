class AddOrderToContentFilesAndMediumPhotos < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :content_files_order, :text, array: true, default: []
    add_column :archive_items, :medium_photos_order, :text, array: true, default: []
  end
end
