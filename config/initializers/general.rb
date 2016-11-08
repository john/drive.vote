# https://github.com/heroku/rack-timeout
# extend timeout for local dev so we can use breakpoints without service resetting
Rack::Timeout.service_timeout = 3600 if Rails.env.development? # seconds
Rack::Timeout.service_timeout = 55 if ENV['DTV_WORKER'] == 'true'
