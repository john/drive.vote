# README

Master: [![CircleCI](https://circleci.com/gh/john/drive.vote.svg?style=svg&circle-token=59230e969a45b9cbd93ef91e357dd64d07db342b)](https://circleci.com/gh/john/drive.vote)
Production: [![CircleCI](https://circleci.com/gh/john/drive.vote/tree/production.svg?style=svg&circle-token=59230e969a45b9cbd93ef91e357dd64d07db342b)](https://circleci.com/gh/john/drive.vote/tree/production)

Drive the Vote helps people arrange free rides to the polls on election day.

Weekly meeting notes [here](
https://docs.google.com/document/d/10g34fvm6qZ-s8ca0TDMET56McxQYUPsc_1dOPFlYoAY/edit?usp=sharing).



## Running the code

### Check out the repo

`git clone git@github.com:john/drive.vote.git; cd drive.vote`

### Set up your environmnt
Create a .env file in the app root and add:

`REDIS_URL=redis://localhost:6379`

### Running it via docker (in dev only!)
1. Install docker. For mac, make sure to use the [Docker Mac Beta](https://docs.docker.com/engine/installation/mac/#/docker-for-mac) and not Docker Toolbox.
1. Run `docker-compose up`. This will start 2 containers: one for postgres, and one that runs rails + webpack dev server.
1. If necessary, run `docker-compose exec bundle exec rails db:create db:migrate db:seed` to setup the database.

Your current directory will be mounted into the docker instances so changes to the files should go live immediately without restarting the envrionment. If you need to restart the rails server, just run `docker-compose up` again.

To get a shell on the current docker instance, run:

```
docker-compose exec bash -l
```

This shouldn't be necessary most of the time.

### Running it directly.
1. Install postgresql.
1. Install Redis
1. Run `rake pg:first_run` on the first run, and `rake pg:start` for subsequent runs to start the DB
1. To set up the db: `rake db:create; rake db:migrate`. To add seed data, `rake db:seed`.
1. Run `rake foreman:dev` to start the server in dev mode.

For production, instead of `foreman:dev`, run
  1. `rake assets:precompile`
  1. `rake foreman:prod`

Do NOT do run rails directly by hand (~~rails server~~). If you do, you will not start the webpack dev server meaning the javascript be available.

### Using Vagrant for development
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
1. `git clone git@github.com:john/drive.vote.git`
1. `cd drive.vote`
1. `vagrant up`
1. `vagrant ssh` to access the virtual machine
1. `cd /opt/drive.vote && rake foreman:dev` to start the app
1. Visit http://192.168.42.100:3000/

## Using the app.
The app is not very functional without a logged in session. To login, visit `localhost:3000/users/sign_in`.
Refer to `db/seed.rb` for login info in dev.

The site's navigation structure is incomplete currently so not all components (eg, admin/dispatch/driver) are
always easily findable. If developing on a component, visit the specific url found in `rake routes`. The following
URLs are useful:

  * http://localhost:3000/admin -- Admin console
  * http://localhost:3000/dispatch/[id] -- Dispatch app. Id should be a number corresponding to the ride zone id. Try id: 1.

## Running tests

`rake spec` executes all tests in the spec directory. Run locally before committing, the app won't deploy if specs don't pass.

## Continuous deployment

When code is merged into master, CircleCI triggers an automatic deployment to https://dev.drive.vote. To deploy to production at https://drive.vote, merge master into the production branch.

## Preparing for manual deployment

Code is typically deployed automatically, this documents manual deploymentCode is deployed using AWS Elastic Beanstalk CLI tool which is a python script. To execute a deploy,
configure a python virtualenv, and run the Elastic Beanstalk CLI tool from there.

### Install virtualenv
1. Install [pip](https://pip.pypa.io/en/stable/installing/) if it isn't there. If you're using Os X, it's likely already installed.
1. Install virtual env. `sudo pip install virtualenv`

### Create a venv in your checkout.
This creates a directory named `venv` which is a little self-consistent Python sandbox that you can install packages into without being root.
1. `virtualenv venv`
1. `pip install -r requirements.pip`

Each time you want to use the venv, run this in your terminal: `source venv/bin/activate`. You'll see the name of the current virtual env to the left of the prompt, eg, (venv) Your-computer: > .

Activate a venv to run DtV `eb` commands and rake deployment tasks.

## Creating a new Elastic Beanstalk environment

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

## Deploying code

### Run your elastic beanstalk commands

Per above make sure you have aws profiles defined in ~/.aws/credentials.


| Command | Description |
| ------- | ----------- |
| `rake deploy:dev` | Deploys to the dev environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. |
| `RAILS_ENV=production NODE_ENV=production rake deploy:prod` | Deploys to the prod environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. Ensure rails and node to run in production mode so the webpack bundle is built with optimizations. |
| `eb printenv` | Prints environment variables the running app is currently figured with. Warning: has secrets. All people that can deploy can see the secrets. |
| `eb setenv A=1 B=2` | Sets new environment variables. This will restart the webservers so combine multiple variable updates on one line. Command blocks until deploy is finished.  |


## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Follow rails [core team coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#write-your-code)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

This software is released under the MIT License. See the LICENSE.md file for more information.

