class AddIndexToArchiveItemsDraft < ActiveRecord::Migration[7.1]
  def change
    add_index :archive_items, :draft, if_not_exists: true
  end
end
