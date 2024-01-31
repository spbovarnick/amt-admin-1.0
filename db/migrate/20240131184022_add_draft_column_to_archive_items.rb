class AddDraftColumnToArchiveItems < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :draft, :boolean, default: false
  end
end
