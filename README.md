# ALBINA COMMUNITY ARCHIVE - Admin CMS & API

This application is built with Ruby on Rails using the latest `importmaps` and `@hotwire/stimulus` controllers to handle JS modules and manipulation of the DOM.

This app is used as an administrative CMS and API to manage and hydrate the content and records of the public-facing Albina Community Archive. For more information about the front end application, please visit [https://github.com/spbovarnick/waf-front-end](https://github.com/spbovarnick/waf-front-end).

### Database

This app is using a postgres database locally and in production.

Before creating the database, copy the sample env vars file. It sets `TARGET_DB` to `localhost`, which `config/database.yml` needs to pick your local database:
```
cp -n config/local_env_vars.rb.sample config/local_env_vars.rb
```

This app uses **PostgreSQL 15** (`db/structure.sql` is dumped from 15.17). Older `psql` versions fail `db:schema:load` with `invalid command \restrict`; the minimum is `psql` 14.19+ or 15.14+. If your Postgres server is an older version, you can install just the 15 client tools and put them first on your PATH without changing the server:
```
brew install postgresql@15
echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
psql --version
```
Don't use `brew link postgresql@15` for this if another Postgres server is running from Homebrew. Linking requires unlinking the other version, which removes files that server reads at runtime.

Then create the database and load the schema:
```
rails db:create db:schema:load
```

**Do not run `rails db:migrate` on a fresh database.** The migrations in `db/migrate` only change tables that were carried over from the original monorepo, so the first one fails on an empty database. `db:schema:load` builds every table from `db/structure.sql` and marks those migrations as already run. If you already ran `db:migrate`, start over with `rails db:drop db:create db:schema:load`. A failed migrate leaves tables behind that make `db:schema:load` fail with `relation "ar_internal_metadata" already exists`.

Run `rails db:seed` to add a sample collection. The archive item form requires a collection, and a fresh database has none. To log in, create an admin user from the console (see [Users](#users)).

Make sure to check `storage.yml` `local` settings to use the the Pathname appropriate to your use case--setting this up from scratch or migrating from the original monorepo.

If you are transitiong from the original version of this project, you can create a copy of your original local db with the following psql command:
```
CREATE DATABASE amt_admin_rails_development
WITH TEMPLATE waf_rails_development
OWNER [Your username];
```

Because ActiveRecord attachments from the original db are stored within the other repo, you'll need to move them to this repo to access them. You can do so from your terminal with the command `cp -r absolute/path/to/original/repo/storage/* absolute/path/to/new/repo/storage`. You can get the absolute path to each repo's storage directory by opening each respective project's console and entering `Rails.root.join("storage")`.

### Local Development

- Make sure you have yarn installed globaly: `npm install --global yarn`
- Make sure you have [redis](https://redis.io/docs/install/install-redis/install-redis-on-mac-os/) installed globally (`brew install redis`) and running while working in development
- Install node modules: `yarn install`
- Don't precompile assets for development. `bin/dev` builds the Sass, and a precompiled `public/assets` folder makes the server keep sending old CSS/JS. If your CSS or JS changes don't show up, run `rails assets:clobber` and restart `bin/dev`.
- The master key stored in the ignored `master.key` file is required to access mailer address and app-specific password, which is stored in `config/credentials.yml.enc`. Ask the team for it. If you don't have it yet, the app fails on boot because `config/environments/development.rb` reads `credentials.development[:gmail]`. To get past this locally, comment out the `config.action_mailer.smtp_settings` block in that file (don't commit the change). Mail won't send until you have the key.
- Rather than `rails s`, boot the development server with the `bin/dev` command, which points to `Procfile.dev` to start the server, watch for `Sass` changes, and run memcached. If you already run memcached as a service (`brew services list`), `bin/dev` exits with `Address already in use`. Start it without memcached instead: `bin/dev -m all=1,memcached=0`. Development only uses memcached when caching is turned on (`rails dev:cache`).
- Due to the production volume of `ArchiveItem` records, the application uses `redis` and `Sidekiq` for the ActiveJob `ExportArchiveItemsCsvJob`. To work on this or other jobs locally, you must run `Sidekiq` locally in a second terminal with the command `bundle exec sidekiq`
- Sidekiq uses Redis database 0 unless `REDIS_URL` is set, and other local apps often share it. When they do, this app's Sidekiq picks up their jobs. `config/local_env_vars.rb.sample` sets `REDIS_URL` to database 2 to avoid that. Change the number if another app already uses 2.

If you encounter the error `[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.` add `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to your `~/.zshrc` or `~/.bashrc`. You can check that the `OBJC_DISABLE_INITIALIZE_FORK_SAFETY` variable is set correctly by opening a fresh terminal from within your IDE and running `echo $OBJC_DISABLE_INITIALIZE_FORK_SAFETY`. If `YES` is returned, go ahead and start the server.

### Using live DB data

If you want to use staging or production data on your local server, update the `TARGET_DB` value in `/config/local_env_vars.rb`. This will point your DB to the correct source, and sync up where static assets are pulled from (local vs S3). Be sure you have all the required env vars filled in your `local_env_vars.rb` file.

Optional values for `TARGET_DB` are:

- `localhost`
- `staging`
- `production`

*NOTE! Be vigilant about your `TARGET_DB` value. Targeting production can result in unwanted mutations to the prod db.

### Asset storage

In the production environment, all files uploaded through the admin are saved to an Amazon S3 bucket. There are different buckets for staging and prod, but what bucket is used is based on the environment's config vars.

### Deployment

The production environment is hosted on Heroku.

If you haven't already, [install the Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli): `npm install -g heroku`

Connect your local repo to both the production app by running `heroku git:remote -a amt-admin` from within your local `amt-admin` directory.

To deploy the main branch to either env run: `git push [remote name] main`.

To deploy any other branch run `git push [remote name] <yourbranch>:master`.
Migrate production ready code from staging to prod using Heroku's "promote" UI.

If you need to run migraions on the Heroku app, run:

- Production: `heroku run rake db:migrate --app <staging-or-prod-app>`

Worker process is scaled to 1, ie `heroku ps:scale worker=1`

### Users

#### Admins

Admin users have unmitigated access through the `admin` namespace, including the UI to create new user accounts or edit extant ones.
<br/>
Admin users can be created through the console (`rails console`) with the following command:

```
User.create!({:email => "someone@gmail.com", :password => "testpass", :password_confirmation => "testpass", :admin => true, :page => "global"})
```

#### Archivists

All non-admin users are considered archiviststs and can access and create Archive Items, all associated Page Data, and Pages. Such users can be created through the console with the following command:
<br/>
Archivists can only access records and pages related to the organization they are working for. Organizational affiliation is indicated with the `:page` key. In the example below, the archivist account will be used by someone working under Albina Music Trust. It is important here that the value entered for `:page` exactly match the tag being used on the associated page.
<br/>
For global access to all archive records, `:page => "global"`
<br/>
Users with archivist authorization can be created through the console with the following command (in this example the archivist is affiliated with Albina Music Trust):

```
User.create!({:email => "someone@gmail.com", :password => "testpass", :password_confirmation => "testpass", :page => "Albina Music Trust"})
```

<br/>
Archivists who should receive the weekly CSV snapshot email need to have have their accounts created or updated with `:snapshot_recipient => true`. See `weekly_csv_snapshot_job.rb` for further details.

### Third Party Tools

**_rails_live_reload_** <br/>
Using this gem for live reload during development. <br/>
[https://github.com/railsjazz/rails_live_reload](https://github.com/railsjazz/rails_live_reload)

**_Devise_** <br/>
Used for account management and authentication for the CMS. <br/>
[https://github.com/heartcombo/devise](https://github.com/heartcombo/devise)

**_Ransack_** <br/>
Used for search. <br/>
[https://github.com/activerecord-hackery/ransack](https://github.com/activerecord-hackery/ransack)

**_Acts as taggable on_** <br/>
Using this gem for tagging functionality on the `ArchiveItem` model. <br/>
[https://github.com/mbleigh/acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)

**_pg-search_** <br/>
Used for faster, indexed, full-text search. <br/>
[https://github.com/Casecommons/pg_search](https://github.com/Casecommons/pg_search)

**_dartsass-rails_**
Use to compile Sass and output CSS.
[https://github.com/rails/dartsass-rails](https://github.com/rails/dartsass-rails)

**_Sidekiq_**
Job handler for CSV export.
[https://github.com/sidekiq/sidekiq](https://github.com/sidekiq/sidekiq)

**_Heroku Key-Value Store_**
In-memory KVS for jobs run by Sidekiq.
[https://devcenter.heroku.com/articles/heroku-redis](https://devcenter.heroku.com/articles/heroku-redis)