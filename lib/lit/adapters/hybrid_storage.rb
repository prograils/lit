require 'redis'
require 'concurrent'

module Lit
  extend self
  def redis
    $redis = Redis.new(url: determine_redis_provider) unless $redis
    $redis
  end

  def determine_redis_provider
    ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']
  end

  def _hash
    $_hash ||= ::Concurrent::Hash.new
  end

  def reset_hash
    $_hash = nil
  end

  def hash_dirty?
    # Hash is considered dirty if hash snapshot is older
    # than Redis snapshot.
    Lit.hash_snapshot < Lit.redis_snapshot
  end

  def hash_snapshot
    $_hash_snapshot ||= DateTime.new
  end

  def hash_snapshot= (timestamp)
    $_hash_snapshot = timestamp
  end

  def redis_snapshot
    timestamp = Lit.redis.get(Lit.prefix + '_snapshot')
    if timestamp.nil?
      timestamp = DateTime.now.to_s
      Lit.redis_snapshot = timestamp
    end
    DateTime.parse(timestamp)
  end

  def redis_snapshot= (timestamp)
    Lit.redis.set(Lit.prefix + '_snapshot', timestamp)
  end

  def determine_redis_provider
    ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']
  end

  def prefix
    pfx = 'lit:'
    if Lit.storage_options.is_a?(Hash)
      pfx += "#{Lit.storage_options[:prefix]}:" if Lit.storage_options.key?(:prefix)
    end
    pfx
  end

  class HybridStorage
    def initialize
      Lit.redis
      Lit._hash
    end

    def [](key)
      if Lit.hash_dirty?
        Lit.hash_snapshot = DateTime.current
        Lit._hash.clear
      end
      if Lit._hash.key? key
        return Lit._hash[key]
      else
        redis_val = get_from_redis(key)
        Lit._hash[key] = redis_val
      end
    end

    def get_from_redis(key)
      if Lit.redis.exists(_prefixed_key_for_array(key))
        Lit.redis.lrange(_prefixed_key(key), 0, -1)
      elsif Lit.redis.exists(_prefixed_key_for_nil(key))
        nil
      else
        Lit.redis.get(_prefixed_key(key))
      end
    end

    def []=(k, v)
      delete(k)
      Lit._hash[k] = v
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
      Lit.redis_snapshot = DateTime.now
      Lit._hash.delete(k)
      Lit.redis.del(_prefixed_key_for_array(k))
      Lit.redis.del(_prefixed_key_for_nil(k))
      Lit.redis.del(_prefixed_key(k))
    end

    def clear
      Lit.redis_snapshot = DateTime.now
      Lit._hash.clear
      Lit.redis.del(keys) if keys.length > 0
    end

    def keys
      Lit.redis.keys(_prefixed_key + '*')
    end

    def has_key?(key)
      Lit._hash.has_key?(key) || Lit.redis.exists(_prefixed_key(key)) # This is a derp
    end

    def incr(key)
      Lit.redis.incr(_prefixed_key(key))
    end

    def sort
      Lit.redis.keys.sort.map do |k|
        [k, self.[](k)]
      end
    end

    private

    def _prefix
      Lit.prefix
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
