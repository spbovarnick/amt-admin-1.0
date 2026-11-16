# Development only: a fresh database has no collections, and the archive item form requires one.
# Skipped elsewhere because saving a Collection also asks the Next.js front end to refresh its cache.
if Rails.env.development?
  Collection.find_or_create_by!(name: "Sample Collection")
end
