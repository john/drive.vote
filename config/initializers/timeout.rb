# from https://github.com/heroku/rack-timeout/issues/60

Rack::Timeout.unregister_state_change_observer(:logger) if Rails.env.development?