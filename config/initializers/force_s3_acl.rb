require "active_storage/service/s3_service"

module ForceS3Acl
  def upload(key, io, checksum: nil, **options)
    # Merge in our desired ACL so that every upload gets "bucket-owner-full-control"
    super(key, io, checksum: checksum, **options.merge(acl: "bucket-owner-full-control"))
  end
end

ActiveStorage::Service::S3Service.prepend(ForceS3Acl)
