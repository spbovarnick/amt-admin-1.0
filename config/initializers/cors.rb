# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3333', 'localhost:3000', 'https://amt-front-end.vercel.app', "https://albinacommunityarchive.org", "https://www.albinacommunityarchive.org"
    resource '*', 
    headers: :any, 
    methods: [:get]
  end
end