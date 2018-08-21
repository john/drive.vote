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

1. `git clone git@github.com:john/drive.vote.git; cd drive.vote`
1. `cd drive.vote`

### Docker
1. [Install docker](https://store.docker.com/search?type=edition&offering=community).
1. Run `docker-compose up`. This will start three containers: one for postgres, one for redis and one that runs rails + the webpack dev server.
1. If necessary, run `docker-compose exec web bundle exec rails db:create db:schema:load db:seed` to setup the database. You'll need to do this on first run.
1. To shut down the DtV containers: `docker-compose stop`

Your current directory will be mounted into the docker instances so changes to the files should go live immediately without restarting the envrionment. If you need to restart the rails server, just run `docker-compose up` again.

To get a shell on the current docker instance, run:

```
docker-compose exec web bash -l
```

This shouldn't be necessary most of the time.


### Directly.
1. Create a .env file in the app root and add these variables, with the correct values for your local env:

  ```
    REDIS_URL=redis://localhost:6379
    SECRET_KEY_BASE=xxxxxxx
  ```

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

## Continuous deployment

When code is merged into master, CircleCI triggers an automatic deployment to https://dev.drive.vote. To deploy to production at https://drive.vote, merge master into the production branch.

## Deployment

### Setup

#### Deployment setup: Preparing for manual deployment

Code is typically deployed automatically, this documents manual deployment. Code is deployed using AWS Elastic Beanstalk CLI tool which is a python script. To execute a deploy,
configure a python virtualenv, and run the Elastic Beanstalk CLI tool from there.

#### Deployment setup: Install virtualenv
1. Install [pip](https://pip.pypa.io/en/stable/installing/) if it isn't there. If you're using Os X, it's likely already installed.
1. Install virtual env. `sudo pip install virtualenv`

#### Deployment setup: Create a venv in your checkout.
This creates a directory named `venv` which is a little self-consistent Python sandbox that you can install packages into without being root.
1. `virtualenv venv`
1. `pip install -r requirements.pip`

Each time you want to use the venv, run this in your terminal: `source venv/bin/activate`. You'll see the name of the current virtual env to the left of the prompt, eg, (venv) Your-computer: > .

Activate a venv to run DtV `eb` commands and rake deployment tasks.

#### Deployment setup: Creating a new Elastic Beanstalk environment

This is to stand up an entirely new environment, it's done infrequently and generally you don't have to worry about it.

If you define profile sections in your ~/.aws/credentials file for drivevote.prod (or dev), then you can set the `AWS_EB_PROFILE` env var before calling the following command in order to use the right set of credentials. Open a termal, start a venv, and run:

```
RAILS_ENV=production NODE_ENV=production  AWS_EB_PROFILE=drivevote.prod eb create drivevote-prod -db -p 'Ruby 2.3 (Puma)' -db.engine postgres -db.i db.t2.micro -i t2.micro --elb-type application -k aws-eb -r us-west-2 -db.user drivevoteprod --envvars SECRET_KEY_BASE=[somesecret],RAILS_SKIP_ASSET_COMPILATION=true,DTV_ACTION_CABLE_ORIGIN=www.drive.vote,PAPERTRAIL_HOST=logs4.papertrailapp.com,PAPERTRAIL_PORT=46774
```

This will configure the main web environment and database.  After this, open up the RDS console to find the newly created database. Use the values there for `[endpoint]` in the command below in order to configure the database access. This is because Elastic Beanstalk has no sane way of sharing an RDS instance between envrionments (wtf?).

```
RAILS_ENV=production NODE_ENV=production  AWS_EB_PROFILE=drivevote.prod eb create drivevote-prod-worker -t worker -p 'Ruby 2.3 (Puma)' -s -k aws-eb -r us-west-2  --envvars "SECRET_KEY_BASE=$(rake secret),RAILS_SKIP_ASSET_COMPILATION=true,DTV_IS_WORKER=TRUE,PAPERTRAIL_HOST=logs4.papertrailapp.com,PAPERTRAIL_PORT=46774,RDS_DB_NAME=ebdb,RDS_HOSTNAME=[endpoint],RDS_PASSWORD=[password],RDS_USERNAME=drivevoteprod,DTV_ACTION_CABLE_ORIGIN=worker-[origin-for-papertrail-logging]"
```

Next, fix the RDS security group to allow writes from the worker. Open up the RDS console for the EB instance and modify its securtiy group's incoming rules to allow access from the worker.

Finally, do a deploy via
```
RAILS_ENV=production NODE_ENV=production  AWS_EB_PROFILE=drivevote.prod rake deploy:prod
```

to ensure the javascript bundle is built.

And finally, you need to update the enviornment to handle https with something like
```
aws elasticbeanstalk --profile drivevote.prod update-environment --environment-name drivevote-prod --option-settings file:///Users/awong/src/DevProgress/drive.vote/elb-prod-acm.json  --region us-west-2
```

### Deploying code

#### Deploying: Run your elastic beanstalk commands

Per above make sure you have aws profiles defined in ~/.aws/credentials.


| Command | Description |
| ------- | ----------- |
| `rake deploy:dev` | Deploys to the dev environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. |
| `RAILS_ENV=production NODE_ENV=production rake deploy:prod` | Deploys to the prod environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. Ensure rails and node to run in production mode so the webpack bundle is built with optimizations. |
| `eb printenv` | Prints environment variables the running app is currently figured with. Warning: has secrets. All people that can deploy can see the secrets. |
| `eb setenv A=1 B=2` | Sets new environment variables. This will restart the webservers so combine multiple variable updates on one line. Command blocks until deploy is finished.  |


## Using the app.
It's recommended to create an entry in /etc/hosts for local.drive.vote, associated with 127.0.0.1. If you do, go to http://local.drive.vote:3000 to log in (or http://localhost:3000 if you don't). To log in as the generic admin use `seeds@drive.vote` as you login email, with password `1234abcd`. Since this account has admin privileges, logging in with it takes you directly to the admin site. If it has only driver privileges, it would take you to the driver app, and if only dispatcher privileges, to the dispatch page for the ride zone attached to your account. If for some reason your account has no privileges at all, you'll end up at the homepage, but that shouldn't happen.

Useful URLs:

  * http://local.drive.vote:3000/admin -- Admin console Default page shows all dev Ride Zones.
  * http://local.drive.vote:3000/dispatch/[slug] -- Dispatch app. The slug should correspond to the ride zone attached to the logged in user. Linked to for each ride from the admin page.
  * http://local.drive.vote/driving -- Driver app. It'll be connected to the Ride Zone the account is driving for.
  
### Spoofing location in the browser
https://www.labnol.org/internet/geo-location/27878/ ?

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
