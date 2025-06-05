# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3333', 'http://localhost:3000', 'https://amt-front-end.vercel.app', "https://albinacommunityarchive.org", "https://www.albinacommunityarchive.org", "https://amt-front-end-staging.vercel.app"
    resource '*',
    headers: :any,
    methods: [:get, :post, :patch, :put]
  end
end