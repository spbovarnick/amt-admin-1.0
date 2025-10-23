class ChangeRedirectLinksTextColumnName < ActiveRecord::Migration[7.1]
  def change
    rename_column(:redirect_links, :text, :url_label)
  end
end
