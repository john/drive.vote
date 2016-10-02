require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class ConfigurationError < StandardError
end

module DriveVote
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    origin = ENV['DTV_ACTION_CABLE_ORIGIN'] || 'wss://drive.vote'
    config.action_cable.url = "#{origin}/cable"
    config.action_cable.allowed_request_origins = [%r{.*drive.vote}, 'https://drivethevote.herokuapp.com']

    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    config.action_mailer.preview_path = "spec/mailers/previews"

    config.twilio_timeout = 5 # seconds

  end
end
