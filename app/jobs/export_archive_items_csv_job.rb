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

      ArchiveItem
        # .pluck(:uid, :search_collections, :title, :created_by, :created_at, :medium, :credit, :year, :search_comm_groups, :search_people, :search_tags)
        # .select(:uid, :search_collections, :title, :created_by, :created_at, :medium, :credit, :year, :search_comm_groups, :search_people, :search_tags)
        .includes( {content_files_attachments: :blob }, :rich_text_content_notes, :rich_text_medium_notes)
        .find_each(batch_size: 50) do |item|

          csv << generate_csv_row(item)

          # # pull content file urls
          # urls = item.content_files.map do |file|
          #   Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
          # rescue => e
          #     "Error: #{e.message}"
          # end.join(", ")

          # # transform block text to plain
          # content_notes = item.content_notes&.to_plain_text || ""
          # medium_notes = item.medium_notes&.to_plain_text || ""

          # row = attributes.map { |attr| item.send(attr) }

          # csv << row + [content_notes, medium_notes, urls]
        end
    end

    # legible/organizational string name
    file_id_string = [Time.now.year, Time.now.mon, Time.now.mday].join('-') + '_' + [ Time.now.hour, Time.now.min, Time.now.sec].join(':')

    s3_key = "exports/archive_items_#{file_id_string}.csv"
    s3_url = upload_to_s3(file.path, s3_key)

    puts "Using AWS key: #{ENV['S3_KEY']&.first(6)}..." if Rails.env.staging?

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
    bucket = s3.bucket(ENV.fetch("CSV_BUCKET_NAME"))

    obj = bucket.object(key)
    obj.upload_file(path, acl: "private")

    credentials = Aws::Credentials.new(
      ENV['S3_KEY'],
      ENV['S3_SECRET']
    )

    # this bucket is private, required getting presigned url via client
    client = Aws::S3::Client.new(
      region: 'us-west-2',
      access_key_id: ENV.fetch('S3_KEY'),
      secret_access_key: ENV.fetch('S3_SECRET')
      # credentials: credentials
    )

    puts "Secret check: #{ENV["S3_SECRET"]}. Key check: #{ENV['S3_KEY']}"

    presigner = Aws::S3::Presigner.new(client: client)

    s3_url = presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch('CSV_BUCKET_NAME'),
      key: obj.key,
      expires_in: 604800
    )

    return s3_url
  end

  def generate_csv_row(item)
    # pull content file urls
    urls = item.content_files.map do |file|
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
    rescue => e
        "Error: #{e.message}"
    end.join(", ")

    # transform block text to plain
    if item.content_notes&.body&.present?
      content_notes = item.content_notes.to_plain_text
    else
      content_notes = ""
    end

    if item.medium_notes&.body&.present?
      medium_notes = item.medium_notes.to_plain_text
    else
      medium_notes = ""
    end

    [
      item.uid,
      item.search_collections,
      item.title,
      item.created_by,
      item.created_at,
      item.medium,
      item.credit,
      item.year,
      item.search_comm_groups,
      item.search_people,
      item.search_tags,
      content_notes,
      medium_notes,
      urls
    ]
  end
end