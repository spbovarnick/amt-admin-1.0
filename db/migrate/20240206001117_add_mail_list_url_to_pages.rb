class AddMailListUrlToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :mail_list_url, :string
  end
end
