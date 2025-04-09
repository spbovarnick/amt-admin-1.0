# config/initializers/force_s3_acl.rb
require "active_storage/service/s3_service"

Rails.application.config.to_prepare do
  ActiveStorage::Service::S3Service.class_eval do
    private

    # This helper returns the S3 object for a given key.
    def object_for(key)
      bucket.object(key)
    end

    # Override the upload method to force the ACL on every upload.
    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        object_for(key).upload_stream(
          body: io,
          content_md5: checksum,
          acl: "bucket-owner-full-control", # Force the ACL here.
          **options
        )
      end
    end
  end
end
