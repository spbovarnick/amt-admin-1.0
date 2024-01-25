class AddDonateLinkToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :donate_url, :string
  end
end
