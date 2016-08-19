module Api
  class ApplicationController < ActionController::Base
    class ConfigurationError < StandardError
    end

    TWILIO_TIMEOUT = 5 # seconds

    protect_from_forgery
  end
end

