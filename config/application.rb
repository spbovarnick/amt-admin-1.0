require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WafAdmin10
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :sidekiq

    # Default (5 minutes) is too short for large direct-to-S3 video uploads on slow
    # connections; the presigned PUT URL expires mid-upload and the whole file has
    # to be re-uploaded from scratch.
    config.active_storage.service_urls_expire_in = 1.hour

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # allows assets/images urls to be used in .scss files
    config.assets.paths << Rails.root.join('app','assets')

    # config.cache_store = :mem_cache_store # Will fallback to $MEMCACHE_SERVERS, then 127.0.0.1:11211
  end
end
