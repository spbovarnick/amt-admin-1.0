class AddRedirectUrlToArchiveItems < ActiveRecord::Migration[7.1]
  def change
    add_column :archive_items, :redirect_url, :string
    add_column :archive_items, :content_redirect, :boolean, :default => false
  end
end
