# WORLD ARTS FOUNDATION INC

This site is built with Ruby on Rails using the latest `importmaps` to handle js files.

### Database

This app is using a postgres database locally and in production.
To create a local database you can run `rails db:create`, and then seed it with data using `rails db:seed`.

If you are transitiong from the original version of this project, you can create a copy of your original local db with the following psql command:
```
CREATE DATABASE waf_admin_rails_development
WITH TEMPLATE waf_rails_development
OWNER [Your username];
```

### Local Development

- Make sure you have yarn installed globaly: `npm install --global yarn`
- Make sure you have [redis](https://redis.io/docs/install/install-redis/install-redis-on-mac-os/) installed globally (`brew install redis`) and running while working in development
- Install node modules: `yarn install`
- Precompile assets: `bundle exec rake assets:precompile`
- The master key stored in the ignored `master.key` file is required to access `google_maps_api_key`, which is stored in `config/credentials.yml.enc`
- The `bin/dev` command points to `Procfile.dev` to start the server and watch for `Sass` changes