namespace :archive_items do

  task add_uids: :environment do
    counter = 0

    MEDIUM_CODES = {
      "photo" => 1,
      "film" => 2,
      "audio" => 3,
      "article" => 4,
      "printed material" => 5
    }.freeze

    ArchiveItem.find_each do |item|
      begin
        next if item.uid.present?

        if !item.search_collections.present?
          puts "Item ID: #{item.id}, Item Title: #{item.title}"
          next
        end

        coll = Collection.find_by(name: item.search_collections)
        coll_id = coll.id
        medium_code = MEDIUM_CODES[item.medium]

        # pad id values with 0's
        coll_str = format('%03d', coll_id)
        medium_str = format('%03d', medium_code)
        item_str = format('%06d', item.id)

        # halve item string for 3rd hyphen
        part1, part2 = item_str[0, 3], item_str[3, 3]

        item.update_column(:uid, "#{coll_str}-#{medium_str}-#{part1}-#{part2}")
        counter += 1
      rescue => e
        puts "Error on ArchiveItem id: #{item.id}, title: #{item.title}"
        puts "#{e.class}: #{e.message}"
      end
    end
    puts "✅ Generated #{counter} UIDs"
  end
end