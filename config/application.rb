require_relative 'boot'
require 'rails/all'

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

    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    config.action_mailer.preview_path = "spec/mailers/previews"

    config.twilio_timeout = 5 # seconds

  end
end
