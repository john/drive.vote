module Api
  class ApplicationController < ActionController::Base
    class ConfigurationError < StandardError
    end

    protect_from_forgery
  end
end

