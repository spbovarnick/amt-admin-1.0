class CreateRedirectLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :redirect_links do |t|
      t.references :archive_items, null: false, foreign_key: true
      t.string :url
      t.string :text
      t.integer :position

      t.timestamps
    end
  end
end
