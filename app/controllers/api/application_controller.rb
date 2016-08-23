module Api
  class ApplicationController < ActionController::Base
    TWILIO_TIMEOUT = 5 # seconds
    protect_from_forgery
  end
end

