class AddFtNamesSearchToArchiveItems < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      ALTER TABLE archive_items
      ADD COLUMN ft_names_search tsvector GENERATED ALWAYS AS (
        (
          setweight(to_tsvector('simple'::regconfig, (COALESCE(search_people, ''::character varying))::text), 'A'::"char") ||
          setweight(to_tsvector('simple'::regconfig, (COALESCE(search_comm_groups, ''::character varying))::text), 'B'::"char") ||
          setweight(to_tsvector('simple'::regconfig, (COALESCE(search_tags, ''::character varying))::text), 'C'::"char") ||
          setweight(to_tsvector('simple'::regconfig, (COALESCE(search_locations, ''::character varying))::text), 'C'::"char")
        )
      ) STORED;

      CREATE INDEX index_archive_items_on_ft_names_search
      ON archive_items USING gin(ft_names_search);
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX index_archive_items_on_ft_names_search;
      ALTER TABLE archive_items DROP COLUMN ft_names_search
    SQL
  end
end
