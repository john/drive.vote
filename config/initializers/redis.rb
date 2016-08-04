if (ENV["REDISCLOUD_URL"] or ENV["REDIS_URL"])
  $redis = Redis.new(ur: (ENV["REDISCLOUD_URL"] or ENV["REDIS_URL"]))
end
