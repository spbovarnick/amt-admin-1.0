class AddUidAndLocationtoCmsFtSearch < ActiveRecord::Migration[7.1]
  def up
    rename_column :archive_items, :location, :physical_location
    remove_index :archive_items, :cms_ft_search
    execute <<~SQL
      ALTER TABLE archive_items DROP COLUMN cms_ft_search;
      ALTER TABLE archive_items ADD COLUMN cms_ft_search tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(search_people, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(search_comm_groups, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(search_tags, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(search_locations, '')), 'C') ||
        setweight(to_tsvector('simple',  COALESCE(uid, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(physical_location, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(search_collections, '')), 'D') ||
        setweight(to_tsvector('english', COALESCE(created_by, '')), 'D') ||
        setweight(to_tsvector('english', COALESCE(updated_by, '')), 'D')
      ) STORED;
    SQL
    add_index :archive_items, :cms_ft_search, using: :gin

  end

  def down
    remove_index :archive_items, :cms_ft_search
    execute <<~SQL
      ALTER TABLE archive_items DROP COLUMN cms_ft_search;
      ALTER TABLE archive_items ADD COLUMN cms_ft_search tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(search_people, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(search_comm_groups, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(search_tags, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(search_locations, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(search_collections, '')), 'D') ||
        setweight(to_tsvector('english', COALESCE(created_by, '')), 'D') ||
        setweight(to_tsvector('english', COALESCE(updated_by, '')), 'D')
      ) STORED;
    SQL
    add_index :archive_items, :cms_ft_search, using: :gin
    rename_column :archive_items, :physical_location, :location
  end
end
