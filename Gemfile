# ruby-gemset=drive.vote
source 'https://rubygems.org'
ruby '2.3.1'

gem 'city-state'
gem 'chronic'
gem 'coffee-rails' # shouldn't be necessary, not using, but one line in /spec/requests/dispatcher_spec.rb fails without it, super weirdly
gem 'devise'
gem 'geocoder'
gem 'geokit-rails'
gem 'google-api-client'
gem 'haml'
gem 'haml-rails'
gem 'humane-rails'
gem 'pg'
gem 'phony_rails'
gem 'prawn'
gem 'puma'
gem 'pundit'
gem 'rack-timeout'
gem 'rails', git: 'https://github.com/rails/rails.git' # switch to 5.1 when released, '>= 5.0.0', '< 5.1'
gem 'redis'
gem 'redis-namespace'
gem 'remote_syslog_logger'
gem 'rolify'
gem 'rspec'
gem 'rspec-rails'
gem 'sass-rails'
gem 'sendgrid'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'timezone'
gem 'tod'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails'
gem 'webpacker', git: 'https://github.com/rails/webpacker.git'
gem 'will_paginate'
# gem 'will_paginate-bootstrap' # I'd like to use this, but it breaks specs, weirdly :/
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
  gem 'webmock', '~> 2.1.0'
end

group :test do
  gem 'factory_girl_rails', require: false
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'watir', require: false
end
