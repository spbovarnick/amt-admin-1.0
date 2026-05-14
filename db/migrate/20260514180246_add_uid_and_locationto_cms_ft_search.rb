class AddUidAndLocationtoCmsFtSearch < ActiveRecord::Migration[7.1]
  def up
    remove_index: archive_items, :cms_ft_search
    execute <<~SQL
      ALTER TABLE archive_items DROP COLUMN cms_ft_search;
      ALTER TABLE archive_items ADD COLUMN cms_ft_search tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector(''))
      )
  end

  def down

  end
end
