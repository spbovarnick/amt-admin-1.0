# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
Ruby v3.2.2

### Database

This app is using a postgres database locally and in production.
To create a local database you can run `rails db:create`, and then seed it with data using `rails db:seed`.

### Local Development

- Make sure you have yarn installed globaly: `npm install --global yarn`
- Make sure you have [redis](https://redis.io/docs/install/install-redis/install-redis-on-mac-os/) installed globally (`brew install redis`) and running while working in development
- Install node modules: `yarn install`
- Precompile assets: `bundle exec rake assets:precompile`
- The master key stored in the ignored `master.key` file is required to access `google_maps_api_key`, which is stored in `config/credentials.yml.enc`

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
