class RemoveRedirectUrlFromArchiveItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :archive_items, :redirect_url, :string
  end
end
