class ArchiveItem < ApplicationRecord
    include PgSearch::Model
    pg_search_scope :search_archive_items,
        against: {
            title: 'A',
            search_people: 'B',
            search_comm_groups: 'B',
            search_tags: 'C',
            search_locations: 'C',
            search_collections: 'D'
    },
        using: { 
            tsearch: { 
                dictionary: 'english', tsvector_column: 'ft_search'
            } 
    }

    pg_search_scope :search_cms_archive_items,
        against: {
            title: 'A',
            search_people: 'B',
            search_comm_groups: 'B',
            search_tags: 'C',
            search_locations: 'C',
            search_collections: 'D',
            created_by: 'D',
            updated_by: 'D'
    },
        using: {
            tsearch: { 
                dictionary: 'english', tsvector_column: 'cms_ft_search' 
            }
    }

    has_one_attached :content_file
    has_many_attached :content_files
    has_one_attached :medium_photo
    has_many_attached :medium_photos
    acts_as_ordered_taggable
    acts_as_ordered_taggable_on :tags, :locations, :people, :comm_groups, :collections
    has_rich_text :content_notes
    has_rich_text :medium_notes
    has_one_attached :poster_image

    # this method copies the taggable 'metadata' from on archive_item to the form for a new one
    def copy_tags_from(other_item)
        %i[tag location person comm_group collection].each do |metadata|
        tag_list = other_item.send("#{metadata.to_s}_list")
        tag_list_string = tag_list.join(", ")
        self.send("#{metadata.to_s}_list=", tag_list_string)
        end
    end
end
