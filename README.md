# README

Master: [![CircleCI](https://circleci.com/gh/john/drive.vote.svg?style=svg&circle-token=59230e969a45b9cbd93ef91e357dd64d07db342b)](https://circleci.com/gh/john/drive.vote)
Production: [![CircleCI](https://circleci.com/gh/john/drive.vote/tree/production.svg?style=svg&circle-token=59230e969a45b9cbd93ef91e357dd64d07db342b)](https://circleci.com/gh/john/drive.vote/tree/production)

[Drive the Vote](https://drive.vote) helps people arrange free rides to the polls on election day. It consists of:
* A text-based interface for voters to request rides on-demand--no smartphone required!
* A scheduling app, so either voters or volunteers can pre-schedule rides.
* An app for dispatchers to monitor voters and volunteer drivers in real-time.
* A location-aware app for drivers, to notify them when a nearby voter has requested or scheduled a ride.

Here's what the Philadelphia dispatch and driver apps looked like on election morning 2016:

![DtV screenshots](https://i.imgur.com/NeS6KCd.png)


## Running the app

### Check out the repo

1. `git clone git@github.com:john/drive.vote.git`
1. `cd drive.vote`

### Preparing your environment

Certain features require you to add a .env file to the root app directory containing these values:

  ```
  SECRET_KEY_BASE=wwww
  TWILIO_SID=xxxx
  TWILIO_TOKEN=yyyy
  GOOGLE_API_KEY=zzzz
  REDIS_URL=redis://localhost:6379
  ```
 
You can generate the value for SECRET_KEY_BASE by running `bundle exec rake secret`.

The Twilio values are used for sms interactions with voters and can be obtained from your Twilio account, which you'll also use to [create a Twilio number](https://github.com/john/drive.vote/wiki/Buying-and-Configuring-Twilio-Numbers) with sms capabilities, and update the ride zone you want to work with to use it.

GOOGLE_API_KEY is used for geolocation, and can be created in the [Google API console](https://console.cloud.google.com/apis/). Enable all geo APIs for the key.

### Option 1: run with Docker (recommended)

1. [Install docker](https://store.docker.com/search?type=edition&offering=community).
1. Run `docker-compose up`. This will start three containers: one for postgres, one for redis and one that runs rails + the webpack dev server.
1. On the first run, or after a schema or seed-data change, run `docker-compose exec web bundle exec rails db:create db:schema:load db:seed` to setup the database.
1. To shut down the DtV containers: `docker-compose stop`

Your current directory will be mounted into the docker instances so changes to the files should go live immediately without restarting the environment. If you need to restart the rails server, just run `docker-compose up` again.

To get a bash shell on the current docker instance, run:

  ```
  docker-compose exec web bash -l
  ```

To get a Rails console on the current docker instance, run:

  ```
  docker-compose exec web bundle exec rails console
  ```

### Option 2: run directly

1. Install postgresql
1. Install Redis (to run: `redis-server /usr/local/etc/redis.conf`)
1. Install bundler: `gem install bundler`
1. Install gems: `bundle install`
1. Run `rake pg:first_run` on the first run, and `rake pg:start` for subsequent runs to start the DB
1. To set up the db: `rake db:create; rake db:migrate; rake db:seed`.
1. bundle exec rails webpacker:install (I think?)
1. Run `bundle exec rake foreman:dev` to start the server in dev mode. You can check Procfile.dev to see the servers this starts.

For production, instead of `foreman:dev`, run
  1. `rake assets:precompile`
  1. `rake foreman:prod`

If you don't want to use foreman, you have to run the rails server (Puma) and the webpack server in separate terminals: `bundle exec rails server` and `bundle exec ./bin/webpack-dev-server`, respectively.

## Running specs

`bundle exec rake spec` executes all tests in the spec directory. Run locally before committing, the app won't deploy if specs don't pass.

If adding or modifying tests that will make new calls to the Google Maps APIs, you'll need to run with a valid `GOOGLE_API_KEY`, both to get your tests to pass, and also to refill the cached test data for use in later runs (including CI). See the discussion in `spec/rails_helpers.rb` for instructions on how to run with a live API Key.

## Running the app locally

Go to http://localhost:3000 and log in as the generic admin with email `seeds@drive.vote` and password `1234abcd`. Since this account has admin privileges, logging in with it takes you directly to the admin site. If it has only driver privileges, it would take you to the driver app, and if only dispatcher privileges, to the dispatch page for the ride zone attached to your account. If for some reason your account has no privileges at all, you'll end up at the homepage, but that shouldn't happen. Note the accounts in seeds.rb don't exist in production, so don't get cute.

Useful URLs:

  * http://localhost:3000/admin -- Admin console Default page shows all dev Ride Zones.
  * http://localhost:3000/dispatch/[slug] -- Dispatch app. The slug should correspond to the ride zone attached to the logged in user. Linked to for each ride zone from the admin page.
  * http://localhost:3000/driving -- Driver app. It'll be connected to the Ride Zone the account is driving for. If this URL redirects to /, it means the account logging in isn't a driver.
  
### Spoofing location in the browser
https://www.labnol.org/internet/geo-location/27878/ ?

### Testing Emails

For features that send emails, run [MailHog](https://github.com/mailhog/MailHog) or [MailCatcher](https://mailcatcher.me/) locally. The development environment is configured to send email to the correct port. On macOS you can use brew to install and run Mailhog:

  ```
  brew update && brew install mailhog
  brew services start mailhog
  ```

Once started you can view the Mailhog client at [http://localhost:8025/](http://localhost:8025/)

## Contributing

1. Fork it
1. Create your feature branch: `git checkout -b my-new-feature`
1. Follow rails [core team coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#write-your-code)
1. Provide test coverage/specs for your changes, and make sure all specs pass: `bundle exec rake`
1. Commit your changes: `git commit -am 'Add some feature'`
1. Push upstream: `git push origin my-new-feature`
1. Create new Pull Request
1. Request a code review
1. After review and approval, merge your own work to master

## License

This software is released under the MIT License. See the LICENSE.md file for more information.
