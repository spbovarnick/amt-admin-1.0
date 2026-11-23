# frozen_string_literal: true

Appsignal.configure do |config|
  config.activate_if_environment("production")
  config.name = "Albina - AMT Admin"
  config.push_api_key = ENV.fetch("APPSIGNAL_PUSH_API_KEY", nil)
end
