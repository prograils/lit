require 'redis'
module Lit
  extend self
  def redis
    $redis ||= nil
    $redis = Redis.new(url: determine_redis_provider) unless $redis
    $redis
  end

  def determine_redis_provider
    Lit.redis_url || ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']
  end

  class RedisStorage
    def initialize
      Lit.redis
    end

    # This handles a change in the redis-rb gem that changes exists => exists?
    def exists?(key)
      # Use recommended binary-returning method create [with this redis-rb commit](https://github.com/redis/redis-rb/commit/bf42fc9e0db4a1719d9b1ecc65aeb20425d44427).
      return Lit.redis.exists?(key) if Lit.redis.respond_to?(:exists?)
      # Fall back with older gem
      Lit.redis.exists(key)
    end
    
    def [](key)
      if self.exists?(_prefixed_key_for_array(key))
        Lit.redis.lrange(_prefixed_key(key), 0, -1)
      elsif self.exists?(_prefixed_key_for_nil(key))
        nil
      else
        Lit.redis.get(_prefixed_key(key))
      end
    end

    def []=(k, v)
      delete(k)
      if v.is_a?(Array)
        Lit.redis.set(_prefixed_key_for_array(k), '1')
        v.each do |ve|
          Lit.redis.rpush(_prefixed_key(k), ve.to_s)
        end
      elsif v.nil?
        Lit.redis.set(_prefixed_key_for_nil(k), '1')
        Lit.redis.set(_prefixed_key(k), '')
      else
        Lit.redis.set(_prefixed_key(k), v)
      end
    end

    def delete(k)
      Lit.redis.del(_prefixed_key_for_array(k))
      Lit.redis.del(_prefixed_key_for_nil(k))
      Lit.redis.del(_prefixed_key(k))
    end

    def clear
      Lit.redis.del(keys) unless keys.empty?
    end

    def keys
      Lit.redis.keys(_prefixed_key + '*')
    end

    def has_key?(key)
      self.exists?(_prefixed_key(key))
    end
    alias key? has_key?

    def incr(key)
      Lit.redis.incr(_prefixed_key(key))
    end

    def sort
      Lit.redis.keys.sort.map do |k|
        [k, self.[](k)]
      end
    end

    def prefix
      _prefix
    end

    private

    def _prefix
      prefix = 'lit:'
      if Lit.storage_options.is_a?(Hash) && Lit.storage_options.key?(:prefix)
        prefix += "#{Lit.storage_options[:prefix]}:"
      end
      prefix
    end

    def _prefixed_key(key = '')
      _prefix + key.to_s
    end

    def _prefixed_key_for_array(key = '')
      _prefix + 'array_flags:' + key.to_s
    end

    def _prefixed_key_for_nil(key = '')
      _prefix + 'nil_flags:' + key.to_s
    end
  end
end
