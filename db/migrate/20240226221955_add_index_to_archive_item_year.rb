class AddIndexToArchiveItemYear < ActiveRecord::Migration[7.1]
  def change
    add_index :archive_items, :year, if_not_exists: true
  end
end
