# ALBINA COMMUNITY ARCHIVE - Admin CMS & API

This application is built with Ruby on Rails using the latest `importmaps` and `@hotwire/stimulus` controllers to handle JS modules and manipulation of the DOM.

This app is used as an administrative CMS and API to manage and hydrate the content and records of the public-facing Albina Community Archive. For more information about the front end application, please visit [https://github.com/spbovarnick/waf-front-end](https://github.com/spbovarnick/waf-front-end).

### Database

This app is using a postgres database locally and in production.
To create a local database you can run `rails db:create`, and then seed it with data using `rails db:seed`.

Make sure to check `storage.yml` `local` settings to use the the Pathname appropriate to your use case--setting this up from scratch or migrating from the original monorepo.

If you are transitiong from the original version of this project, you can create a copy of your original local db with the following psql command:
```
CREATE DATABASE waf_admin_rails_development
WITH TEMPLATE waf_rails_development
OWNER [Your username];
```

Because ActiveRecord attachments from the original db are stored within the other repo, you'll need to move them to this repo to access them. You can do so from your terminal with the command `cp -r absolute/path/to/original/repo/storage/* absolute/path/to/new/repo/storage`. You can get the absolute path to each repo's storage directory by opening each respective project's console and entering `Rails.root.join("storage")`.

### Local Development

- Make sure you have yarn installed globaly: `npm install --global yarn`
- Make sure you have [redis](https://redis.io/docs/install/install-redis/install-redis-on-mac-os/) installed globally (`brew install redis`) and running while working in development
- Install node modules: `yarn install`
- Precompile assets: `bundle exec rake assets:precompile`
- The master key stored in the ignored `master.key` file is required to access mailer address and app-specific password, which is stored in `config/credentials.yml.enc`
- Rather than `rails s`, boot the development server with the `bin/dev` command, which points to `Procfile.dev` to start the server and watch for `Sass` changes

If you encounter the error `[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.` add `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to your `~/.zshrc` or `~/.bashrc`. You can check that the `OBJC_DISABLE_INITIALIZE_FORK_SAFETY` variable is set correctly by opening a fresh terminal from within your IDE and running `echo $OBJC_DISABLE_INITIALIZE_FORK_SAFETY`. If `YES` is returned, go ahead and start the server.

### Using live DB data

If you want to use staging or production data on your local server, update the `TARGET_DB` value in `/config/local_env_vars.rb`. This will point your DB to the correct source, and sync up where static assets are pulled from (local vs S3). Be sure you have all the required env vars filled in your `local_env_vars.rb` file.

Optional values for `TARGET_DB` are:

- `localhost`
- `staging`
- `production`

### Asset storage

In the production environment, all files uploaded through the admin are saved to an Amazon S3 bucket. There are different buckets for staging and prod, but what bucket is used is based on the environment's config vars.

### Deployment

The production environment is hosted on Heroku.

If you haven't already, [install the Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli): `npm install -g heroku`

Connect your local repo to both the production app by running `heroku git:remote -a amt-prod` from within your local `amt-admin` directory.

To deploy the main branch to either env run: `git push [remote name] main`.

To deploy any other branch run `git push [remote name] <yourbranch>:master`.
Migrate production ready code from staging to prod using Heroku's "promote" UI.

If you need to run migraions on the Heroku app, run:

- Staging: `heroku run rake db:migrate`
- Production: `heroku run rake db:migrate --app amt-prod`

### Users

#### Admins

Admin users have unmitigated access through the `admin` namespace, including the UI to create new user accounts or edit extant ones.
<br/>
Admin users can be created through the console with the following command:

```
User.create!({:email => "someone@gmail.com", :password => "testpass", :password_confirmation => "testpass", :admin => true, :page => "global"})
```

#### Archivists

Users with archivist authorization can access and create Archive Items, all associated Page Data, and Pages. Such users can be created through the console with the following command:
<br/>
Archivists can only access records and pages related to the organization they are working for. Organizational affiliation is indicated with the `:page` key. In the example below, the archivist account will be used by someone working under Albina Music Trust. It is important here that the value entered for `:page` exactly match the tag being used on the associated page.
<br/>
For global access to all archive records, `:page => "global"`
<br/>
Users with archivist authorization can be created through the console with the following command (in this example the archivist is affiliated with Albina Music Trust):

```
User.create!({:email => "someone@gmail.com", :password => "testpass", :password_confirmation => "testpass", :archivist => true, :page => "Albina Music Trust"})
```

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