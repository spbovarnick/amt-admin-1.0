class AddUiDtoArchiveItems < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :uid, :string
    add_index :archive_items, :uid, unique: true
  end
end
