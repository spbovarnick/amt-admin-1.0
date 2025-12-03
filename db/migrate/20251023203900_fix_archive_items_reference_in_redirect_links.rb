class FixArchiveItemsReferenceInRedirectLinks < ActiveRecord::Migration[7.1]
  def change
    rename_column :redirect_links, :archive_items_id, :archive_item_id

    remove_foreign_key :redirect_links, :archive_items

    add_foreign_key :redirect_links, :archive_items, column: :archive_item_id
  end
end
