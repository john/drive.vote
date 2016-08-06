# /config/initializers/sidekiq.rb

# redis_url = Rails.env.development? ? 'redis://localhost:6379/0' : (ENV["REDISCLOUD_URL"] || ENV["REDIS_URL"])
redis_url = Rails.env.development? ? 'redis://localhost:6379/0' : ENV['REDISCLOUD_URL']

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: "dtv_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: "dtv_#{Rails.env}" }
end