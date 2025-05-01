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

    # has_one_attached :content_file
    has_many_attached :content_files
    has_one_attached :medium_photo
    has_many_attached :medium_photos
    acts_as_ordered_taggable
    acts_as_ordered_taggable_on :tags, :locations, :people, :comm_groups, :collections
    has_rich_text :content_notes
    has_rich_text :medium_notes
    has_one_attached :poster_image

    # validations
    validates :medium, presence: true, inclusion: { in: ["photo","film","audio","article","printed material"] }
    # validates :collections, presence: true

    # sets uid upon record creation, update
    after_commit :set_uid!, on: [:create, :update]

    # this method copies the taggable 'metadata' from on archive_item to the form for a new one
    def copy_tags_from(other_item)
        %i[tag location person comm_group collection].each do |metadata|
        tag_list = other_item.send("#{metadata.to_s}_list")
        tag_list_string = tag_list.join(", ")
        self.send("#{metadata.to_s}_list=", tag_list_string)
        end
    end

    private

    MEDIUM_CODES = {
        "photo" => 1,
        "film" => 2,
        "audio" => 3,
        "article" => 4,
        "printed material" => 5
    }.freeze

    # method for setting UID upon record creation
    # UID is set here, because including record ID in #new UI, requires manipulating values in real time
    def set_uid!

        coll = Collection.find_by(name: collection_list.first)
        coll_id = coll.id
        medium_code = MEDIUM_CODES[medium]

        # pad id values with 0's
        coll_str = format('%03d', coll_id)
        medium_str = format('%03d', medium_code)
        item_str = format('%06d', id)

        # halve item string for 3rd hyphen
        part1, part2 = item_str[0, 3], item_str[3, 3]

        update_column(:uid, "#{coll_str}-#{medium_str}-#{part1}-#{part2}")
    end
end
