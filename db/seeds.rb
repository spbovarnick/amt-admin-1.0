# Development only: the archive item form requires a collection, and its people, location, tag and
# community group fields only accept existing records, so a fresh database can't fill them in.
# Skipped elsewhere because saving these records also asks the Next.js front end to refresh its cache.
if Rails.env.development?
  Collection.find_or_create_by!(name: "Sample Collection")
  Person.find_or_create_by!(name: "Sample Person")
  ArchiveTag.find_or_create_by!(name: "Sample Tag")
  CommGroup.find_or_create_by!(name: "Sample Community Group")
  Location.find_or_create_by!(name: "Sample Location") do |location|
    location.lat = "45.5480"
    location.lng = "-122.6680"
  end
end
