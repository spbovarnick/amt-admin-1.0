require "net/http"
require "uri"
require "json"

module NextRevalidation
  class Publisher
    def self.call(tags: [], paths: [])
      new(tags: tags, paths: paths).call
    end

    def initialize(tags: [], paths: [])
      @tags = Array(tags).compact.map(&:to_s).uniq
      @paths = Array(paths).compact.map(&:to_s).uniq
    end

    def call
      return if @tags.empty? && @paths.empty?
      return unless enabled?

      uri = URI("#{next_app_url}/api/revalidate")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = { tags: @tags, paths: @paths }.to_json

      response = http.request(request)

      Rails.logger.info(
        "Next revalidation response status=#{response.code} body=#{response.body}"
      )

      response

    rescue => e
      Rails.logger.error(
        "Next revalidation failed tags=#{@tags.inspect} paths=#{@paths.inspect} error=#{e.class}: #{e.message}"
      )
      nil
    end

    private

    def enabled?
      next_app_url.present? && revalidate_secret.present?
    end

    def next_app_url
      case ENV["TARGET_DB"]
      when "localhost"
        ENV["NEXT_DEV_URL"]
      when "staging"
        ENV["NEXT_STAGING_URL"]
      when "production"
        ENV["NEXT_PROD_URL"]
      end
    end

    def revalidate_secret
      ENV["REVALIDATE_SECRET"]
    end

    def headers
      {
        "Content-Type" => "application/json",
        "X-Revalidate-Secret" => revalidate_secret
      }
    end
  end
end