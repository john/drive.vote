# /config/initializers/sidekiq.rb

redis_url = Rails.env.development? ? 'redis://localhost:6379/0' : ENV['REDIS_PROVIDER']

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_url, :namespace => 'dtv' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => redis_url, :namespace => 'dtv' }
end