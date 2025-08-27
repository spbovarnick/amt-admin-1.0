class SetDefaultOfArchiveItemsFeaturedItem < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:archive_items, :featured_item, from: nil, to: false)
  end
end
