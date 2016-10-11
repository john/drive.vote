# /config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: "dtv_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: "dtv_#{Rails.env}" }
end
