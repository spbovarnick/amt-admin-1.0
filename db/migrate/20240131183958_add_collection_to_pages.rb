class AddCollectionToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :collection, :string
  end
end
