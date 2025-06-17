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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # allows assets/images urls to be used in .scss files
    config.assets.paths << Rails.root.join('app','assets')

    config.cache_store = :mem_cache_store,
    (ENV['MEMCACHIER_SERVERS'] || "").split(","),
    {
      :username => ENV["MEMCACHIER_USERNAME"],
      :password => ENV["MEMCACHIER_PASSWORD"],
      :failover => true,
      :socket_timeout => 1.5,
      :socket_failure_delay => 0.2,
      :down_retry_delay => 60
    }
  end
end
