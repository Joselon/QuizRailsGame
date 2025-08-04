class OnlineUsers
  def self.redis
    AppRedisClient.instance.redis
  end

  def self.online_ids
    keys = redis.keys("user:*:online")
    keys.map { |key| key.match(/user:(\d+):online/)[1].to_i }
  end

  def self.count
    online_ids.size
  end

  def self.users
    User.where(id: online_ids)
  end
end
