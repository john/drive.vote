#ruby=2.3.1
#ruby-gemset=drive.vote
source 'https://rubygems.org'

gem 'city-state'
gem 'chronic'
gem 'devise'
gem 'geocoder'
gem 'geokit-rails'
gem 'google-api-client'
gem 'haml-rails'
gem 'humane-rails'
gem 'pg'
gem 'phony_rails'
gem 'puma'
gem 'pundit'
gem 'rack-timeout'
gem 'rails', '>= 5.0.0', '< 5.1'
gem 'redis'
gem 'redis-namespace'
gem 'rolify'
gem 'rspec'
gem 'rspec-rails'
gem 'sass-rails', '~> 5.0'
gem 'sendgrid'
gem 'sidekiq'
gem 'sinatra', '~> 2.0.0.beta2', :require => false # for sidekiq
github 'sinatra/sinatra' do
  gem 'rack-protection'
end
gem 'timezone'
gem 'tod'
gem 'turbolinks', '~> 5.x'
gem 'twilio-ruby'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails'
gem 'webpack-rails'
gem 'zip-codes'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
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
end

gem 'foreman'