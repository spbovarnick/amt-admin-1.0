class ExtractId3TagsJob < ApplicationJob
  queue_as :default

  def perform(archive_item_id)
    ArchiveItem.find(archive_item_id).extract_id3_tags!
  end
end
