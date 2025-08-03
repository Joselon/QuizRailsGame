require "singleton"
require "redis"

class AppRedisClient
  include Singleton

  def initialize
    Rails.logger.info("Inicializando RedisClient singleton")
    @redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
  end

  def redis
    @redis
  end
end
