# ruby-gemset=drive.vote
source 'https://rubygems.org'
ruby '2.5.1'

gem 'activestorage'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.1.0', require: false
gem 'chronic', '0.10.2'
gem 'coffee-rails' # shouldnt be necessary, not using, but one line in /spec/requests/dispatcher_spec.rb fails without it, super weirdly
gem 'devise', '4.4.3'
gem 'geocoder', '1.5.0'
gem 'geokit-rails', '2.3.1'
gem 'google-api-client', '0.10.1'
gem 'haml-rails', '1.0.0'
gem 'humane-rails'
gem 'nokogiri'
gem 'pg', '1.0.0'
gem 'phony_rails', '0.14.5' # <---------------- UPGRADING THIS to 0.14.7 BROKE HALF THE FUCKING SPECS.
gem 'prawn', '2.2.2'
gem 'puma', '3.12.0'
gem 'pundit', '1.1.0'
gem 'rack-timeout', '0.4.2'
gem 'rails', '5.2.1'
gem 'redis', '3.3.3'
gem 'redis-namespace', '1.5.3'
gem 'remote_syslog_logger', '1.0.3'
gem 'rolify', '5.1.0'
gem 'rspec', '3.5.0'
gem 'rspec-rails', '3.5.2'
gem 'sass-rails', '5.0.6'
gem 'sidekiq', '4.2.10'
gem 'sinatra', '1.0', require: false
gem 'timezone', '1.2.6'
gem 'tod', '2.1.0'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby', '4.13.0'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails', '1.8.3'
gem 'webpacker', '1.1'
gem 'will_paginate', '3.1.5'
# # gem 'will_paginate-bootstrap' # I'd like to use this, but it breaks specs, weirdly :/
gem 'zip-codes'

group :development do
  gem 'foreman'
  gem 'web-console'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  # A mini view framework for console/irb: https://github.com/cldwalker/hirb
  gem 'hirb', '~> 0.7.3'
end

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'vcr', '~> 3.0.3'
  gem 'webmock', '~> 3.4.2'
end

group :test do
  gem 'factory_girl_rails', '4.7.0', require: false
  gem 'shoulda-matchers', '3.1.1'
  gem 'rails-controller-testing', '1.0.1'
  gem 'timecop', '0.8.1'
  gem 'watir', '6.2.1', require: false
end
