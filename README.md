# README

Drive the Vote helps people arrange free rides to the polls on election day.

Weekly meeting notes [here](
https://docs.google.com/document/d/10g34fvm6qZ-s8ca0TDMET56McxQYUPsc_1dOPFlYoAY/edit?usp=sharing).

## Running the code
1. Install postgresql.
1. Install Redis
1. Run `rake pg:first_run` on the first run, and `rake pg:start` for subsequent runs to start the DB
1. Run `rake foreman:dev` to start the server in dev mode.

For production, instead of `foreman:dev`, run
  1. `rake assets:precompile`
  1. `rake foreman:prod`

Do NOT do run rails directly by hand. If you do, you will not start the webpack dev server meaning the javascript be available.

## Using Vagrant for development
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
1. `git clone git@github.com:john/drive.vote.git`
1. `cd drive.vote`
1. `vagrant up`
1. `vagrant ssh` to access the virtual machine
1. `cd /opt/drive.vote && rake foreman:dev` to start the app
1. Visit http://192.168.42.100:3000/

## Deploying the code
Code is deployed using AWS Elastic Beanstalk CLI tool which is a python script. To execute a deploy,
configure a python virtualenv and run the Elastic Beanstalk CLI tool from there. After the virtualenv is created, the standard
steps are scripted via

```
rake deploy:dev
```

Prod URL (cloudflare): https://drive.vote.

EB direct URL: https://dtv-dev.us-west-2.elasticbeanstalk.com.

## Createing a new Elastic Beanstalk environment

You need a command like:
```
RAILS_ENV=production NODE_ENV=production  AWS_EB_PROFILE=drivevote.prod eb create drivevote-prod -db -p 'Ruby 2.3 (Puma)' -db.engine postgres -db.i db.t2.micro -i t2.micro --elb-type application -k aws-eb -r us-west-2 -db.user drivevoteprod --envvars RAILS_SECRET=[somesecret],RAILS_SKIP_ASSET_COMPILATION=true
```

Then do a deploy via
```
RAILS_ENV=production NODE_ENV=production  AWS_EB_PROFILE=drivevote.prod rake deploy:prod
```

to ensure the javascript bundle is built.

And finally, you need to update the enviornment to handle https with something like
```
aws elasticbeanstalk --profile drivevote.prod update-environment --environment-name drivevote-prod --option-settings file:///Users/awong/src/DevProgress/drive.vote/elb-prod-acm.json  --region us-west-2
```

### Bootstrap python
1. Install [pip](https://pip.pypa.io/en/stable/installing/) if it isn't there. If you're using Os X, it's likely already installed.
1. Install virtual env. `sudo pip install virtualenv`

### Create a virtualenv in your checkout.
This creates a directory named `venv` which is a little self-consistent Python sandbox that you can install packages into without being root.
1. `virtualenv venv`
1. `source venv/bin/activate`  --  Do this for each new shell
1. `pip install -r requirements.pip`

### Run your elastic beanstalk commands

Note, if you use profile sections in your ~/.aws/credentials file, then you can set the `AWS_EB_PROFILE` env var before calling the following command in order to use the right set of credentials.

| Command | Description |
| ------- | ----------- |
| `rake deploy:dev` | Deploys to the dev environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. |
| `RAILS_ENV=production NODE_ENV=production rake deploy:prod` | Deploys to the prod environment in `.elasticbeanstalk/config.yml` from `HEAD` (yes! the last commit! not necessarily what's on your filesystem!). Command blocks until deploy is finished. Ensure rails and node to run in production mode so the webpack bundle is built with optimizations. |
| `eb printenv` | Prints environment variables the running app is currently figured with. Warning: has secrets. All people that can deploy can see the secrets. |
| `eb setenv A=1 B=2` | Sets new environment variables. This will restart the webservers so combine multiple variable updates on one line. Command blocks until deploy is finished.  |


## Using the app.
The app is not very functional without a logged in session. To login, visit `localhost:3000/users/sign_in`.
Refer to `db/seed.rb` for login info in dev.

The site's navigation structure is incomplete currently so not all components (eg, admin/dispatch/driver) are
always easily findable. If developing on a component, visit the specific url found in `rake routes`. The following
URLs are useful:

  * http://localhost:3000/admin -- Admin console
  * http://localhost:3000/dispatch/[id] -- Dispatch app. Id should be a number corresponding to the ride zone id. Try 1.

TODO(awong): Add a sign-in button and improve nav structure for at least development.


## Running tests

`rake spec` executes all tests in the spec directory.


## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Follow rails [core team coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#write-your-code)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

This software is released under the MIT License. See the LICENSE.md file for more information.
