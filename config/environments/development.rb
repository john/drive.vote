Rails.application.configure do
  Rails.env = 'development'
  
  # Websocket for messages
  config.action_cable.url = "ws://local.drive.vote:3000/cable"
  config.action_cable.allowed_request_origins = ['http://local.drive.vote:3000']
  
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end



  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.assets.quiet = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  
  # More info here:
  # http://weblog.rubyonrails.org/2015/1/16/This-week-in-Rails-tokens-migrations-method-source-and-more/
  config.active_record.time_zone_aware_types = [:datetime, :time]

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
