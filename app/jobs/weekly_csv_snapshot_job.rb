# NOTE to test this in staging, the heroku scheduler add-on must be attached to the staging application. see details here: https://devcenter.heroku.com/articles/scheduler#installing-the-add-on


require 'csv'
class WeeklyCsvSnapshotJob < ApplicationJob
  queue_as :default

  def perform()
    aws_key = ENV['S3_KEY']
    aws_secret = ENV['S3_SECRET']
    aws_bucket = ENV['CSV_BUCKET_NAME']

    puts "Job started at #{Time.now}"
    # users are selected programmatically from those with the special designation snapshot_recipient: true, in both dev and in prod
    users = User.where(snapshot_recipient: true).map { |u| u.email}
    file = Tempfile.new(["archive_items", ".csv"])

    # select columns and headers to use
    attributes = %w{ uid search_collections title created_by created_at updated_at medium credit year search_comm_groups search_people search_locations search_tags }
    headers = [ "UID",  "Collection",  "Title",  "Created By",  "Created At", "Last Updated",  "Medium",  "Credit",  "Year",  "Community Groups",  "People", "Location", "Tags", "Content Notes", "Medium Technical Notes", "Content Files", "Filenames", "Published" ]

    # write csv
    CSV.open(file.path, "w") do |csv|
      csv << headers

      ArchiveItem
        .includes( {content_files_attachments: :blob }, :rich_text_content_notes, :rich_text_medium_notes)
        .find_each(batch_size: 50) do |item|

          csv << generate_csv_row(item)
        end
    end

    # legible/organizational string name
    file_id_string = [Time.now.year, Time.now.mon, Time.now.mday].join('-') + '_' + [ Time.now.hour, Time.now.min, Time.now.sec].join(':')

    obj_key = "exports/archive_items_#{file_id_string}.csv"
    s3_url = upload_to_s3(
      path: file.path,
      object_key: obj_key,
      access_key: aws_key,
      secret_key: aws_secret,
      bucket_name: aws_bucket
    )

    WeeklyCsvMailer.with(users:, url: s3_url).csv_ready.deliver_later
    puts "Successfully uploaded to: #{s3_url}"
    puts "Job finished at #{Time.now}"
  ensure
    file&.close
    file&.unlink
  end

  private

  def upload_to_s3(path:, object_key:, access_key:, secret_key:, bucket_name:)

    creds = Aws::Credentials.new(access_key, secret_key)
    s3 = Aws::S3::Resource.new(
      region: 'us-west-2',
      credentials: creds,
      )

    bucket = s3.bucket(bucket_name)
    obj = bucket.object(object_key)
    obj.upload_file(path, acl: "private")

    # this bucket is private, required getting presigned url via client
    client = Aws::S3::Client.new(
      region: 'us-west-2',
      credentials: creds,
    )

    presigner = Aws::S3::Presigner.new(client: client)

    s3_url = presigner.presigned_url(
      :get_object,
      bucket: bucket_name,
      key: obj.key,
      expires_in: 604800,
    )

    return s3_url
  end

  def generate_csv_row(item)
    # pull content file urls
    urls = item.content_files.map do |file|
      blob_url(file)
    rescue => e
      "Error: #{e.message}"
    end.join(", ")

    filenames = item.content_files.map do |file|
      name_arr = file.filename.to_s
    rescue => e
      "Error: #{e.message}"
    end

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
      item.updated_at,
      item.medium,
      item.credit,
      item.year,
      item.search_comm_groups,
      item.search_people,
      item.search_locations,
      item.search_tags,
      content_notes,
      medium_notes,
      urls,
      filenames.join(', '),
      !item.draft
    ]
  end

  def blob_url(file)
    if Rails.env.production? || Rails.env.staging?
      return "http://#{ENV.fetch('S3_BUCKET')}.s3.us-west-2.amazonaws.com/#{file.key}"
    else
      return Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
    end
  end
end