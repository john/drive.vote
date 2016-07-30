if ENV["REDISCLOUD_URL"]
  $redis = Redis.new(ur: ENV["REDISCLOUD_URL"])
end