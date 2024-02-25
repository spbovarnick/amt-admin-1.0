class DropNewsItems < ActiveRecord::Migration[7.1]
  def change
    drop_table :news_items
  end
end
