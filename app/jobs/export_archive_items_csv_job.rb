require 'csv'
class ExportArchiveItemsCsvJob < ApplicationJob
  queue_as :default
  def perform(user_id)
    puts "Job started at #{Time.now}"
    user = User.find(user_id)
    file = Tempfile.new(["archive_items", ".csv"])

    # select columns and headers to use
    attributes = %w{ uid search_collections title created_by created_at medium credit year search_comm_groups search_people search_tags }
    headers = [ "UID",  "Collection",  "Title",  "Created By",  "Created At",  "Medium",  "Credit",  "Year",  "Community Groups",  "People",  "Tags", "Content Notes", "Medium Technical Notes", "Content Files" ]

    # write csv
    CSV.open(file.path, "w") do |csv|
      csv << headers

      # pull content file urls
      ArchiveItem.includes( {content_files_attachments: :blob }, :rich_text_content_notes, :rich_text_medium_notes).find_each(batch_size: 100) do |item|
        urls = item.content_files.map do |file|
          Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
        rescue => e
            "Error: #{e.message}"
        end.join(", ")

        # transform block text to plain
        content_notes = item.content_notes&.to_plain_text || ""
        medium_notes = item.medium_notes&.to_plain_text || ""

        row = attributes.map { |attr| item.send(attr) }

        csv << row + [content_notes, medium_notes, urls]
      end
    end

    # legible/organizational string name
    file_id_string = [Time.now.year, Time.now.mon, Time.now.mday].join('-') + '_' + [ Time.now.hour, Time.now.min, Time.now.sec].join(':')

    s3_key = "exports/archive_items_#{file_id_string}.csv"
    s3_url = upload_to_s3(file.path, s3_key)

    CsvMailer.with(user:, url: s3_url).csv_ready.deliver_later
    puts "Successfully uploaded to: #{s3_url}"
    puts "Job finished at #{Time.now}"
  ensure
    file&.close
    file&.unlink
  end

  private

  def upload_to_s3(path, key)
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    bucket = s3.bucket(ENV["CSV_BUCKET_NAME"])

    obj = bucket.object(key)
    obj.upload_file(path, acl: "private")

    # this bucket is private, required getting presigned url via client
    client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    presigner = Aws::S3::Presigner.new(client: client)

    s3_url = presigner.presigned_url(
      :get_object,
      bucket: ENV['CSV_BUCKET_NAME'],
      key: obj.key,
      expires_in: 604800
    )

    return s3_url
  end
end