require 'redis'
module Lit
  extend self
  def redis
    return @redis if @redis
    @redis = Redis.connect(:thread_safe => true)
    @redis
  end
  class RedisStorage
    def initialize
      Lit.redis
    end

    def [](key)
      Lit.redis.get(key)
    end

    def []=(k, v)
      Lit.redis.set(k.to_s, v.to_s)
    end

    def clear
      Lit.redis.flushall
      save
    end

    def keys
      Lit.redis.keys
    end

    def has_key?(key)
      Lit.redis.exists(key)
    end
  end
end