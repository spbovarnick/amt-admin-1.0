# config/initializers/force_s3_acl.rb
require "active_storage/service/s3_service"

module ForceS3Acl
  def upload(key, io, checksum: nil, **options)
    instrument :upload, key: key, checksum: checksum do
      bucket.object(key).upload_stream(
        body: io,
        content_md5: checksum,
        acl: "bucket-owner-full-control",  # Force this ACL on every upload
        **options
      )
    end
  end
end

ActiveStorage::Service::S3Service.prepend(ForceS3Acl)
