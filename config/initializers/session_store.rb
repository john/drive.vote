# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_drive_vote_session'

# an attempt to fix that fsevent process leak, which is maddening

if Rails.env = 'development'
  Rails.application.config.file_watcher = ActiveSupport::FileUpdateChecker
end