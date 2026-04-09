class AddLocationToArchiveItems < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :location, :string
  end
end
