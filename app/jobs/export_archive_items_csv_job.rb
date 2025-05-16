require 'csv'
class ExportArchiveItemsCsvJob < ApplicationJob
  queue_as :default
  def perform(user_id)
    user = User.find(user_id)
    file = Tempfile.new(["archive_items", ".csv"])

    attributes = %w{ uid search_collections title created_by created_at medium credit year search_comm_groups search_people search_tags }
    headers = [ "UID",  "Collection",  "Title",  "Created By",  "Created At",  "Medium",  "Credit",  "Year",  "Community Groups",  "People",  "Tags", "Content Notes", "Medium Technical Notes", "Content Files" ]

    CSV.open(file.path, "w") do |csv|
      csv << headers

      ArchiveItem.includes( {content_files_attachments: :blob }, :rich_text_content_notes, :rich_text_medium_notes).find_each(batch_size: 100) do |item|
        urls = item.content_files.map do |file|
          Rails.application.routes.url_helpers.url_for(file)
        rescue => e
            "Error: #{e.message}"
        end.join(", ")

        content_notes = item.content_notes&.to_plain_text || ""
        medium_notes = item.medium_notes&.to_plain_text || ""

        row = attributes.map { |attr| item.send(attr) }

        csv << row + [content_notes, medium_notes, urls]
      end
    end

    s3_key = "exports/archive_items_#{Time.now.to_i}.csv"
    s3_url = upload_to_s3(file.path, s3_key)

    CsvMailer.with(user:, url: s3_url).csv_ready.deliver_later
    puts "Successfully uploaded to: #{s3_url}" if Rails.env.development?
  ensure
    file&.close
    file&.unlink
  end

  private

  def upload_to_s3(path, key)
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    bucket = s3.bucket(ENV.fetch("S3_BUCKET_NAME"))

    obj = bucket.object(key)
    obj.upload_file(path, acl: "private")

    obj.presigned_url(:get, expires_in: 604800)
  end
end