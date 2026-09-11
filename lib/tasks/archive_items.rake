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

  # Enqueues one ExtractId3TagsJob per audio item instead of running extraction inline, so the worker dyno's Sidekiq concurrency (see config/sidekiq.yml) processes items in parallel rather than one full-file download at a time. This task itself returns almost immediately -- the actual backfill finishes asynchronously; watch the Sidekiq queue (or re-run this task later, which is a no-op for anything already tagged) to see when it's done.
  task backfill_id3_tags: :environment do
    counter = 0

    ArchiveItem.where(medium: "audio").find_each do |item|
      next unless item.content_files.attached?

      ExtractId3TagsJob.perform_later(item.id)
      counter += 1
    end

    puts "✅ Enqueued ID3 extraction for #{counter} audio items"
  end

  # Reports audio items that still need attention after a backfill_id3_tags run. Flags two distinct cases, both meaning "extraction never really succeeded": - no "id3" key at all (extraction raised -- missing S3 object, unreadable file, or it just hasn't been processed yet) - an "id3" key present but completely empty, with no duration even. wahwah doesn't raise on unparseable content when a plausible extension is present -- it just returns an all-nil Tag -- so this key can end up looking "done" without ever having parsed real audio. A genuinely valid but untagged file still gets a real duration out of the MPEG frame data, so an empty hash (not even duration) is the tell that something's off. Read-only -- doesn't change anything, safe to re-run anytime.
  task audio_missing_id3: :environment do
    missing_id3 = 0

    ArchiveItem.where(medium: "audio").includes(content_files_attachments: :blob).find_each do |item|
      next unless item.content_files.attached?

      bad_files = item.content_files.select do |f|
        f.blob.audio? && f.blob.metadata["id3"].blank?
      end
      next if bad_files.empty?

      reasons = bad_files.map { |f| f.blob.metadata.key?("id3") ? "empty" : "never processed" }.uniq.join(", ")
      puts "#{item.uid.presence || item.id} - #{item.title} (#{reasons})"
      missing_id3 += 1
    end

    puts "✅ #{missing_id3} item(s) missing id3 data"
  end
end