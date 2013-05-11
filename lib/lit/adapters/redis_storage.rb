require 'redis'
module Lit
  extend self
  def redis
    $redis = Redis.connect unless $redis
    $redis
  end
  class RedisStorage
    def initialize
      Lit.redis
    end

    def [](key)
      Lit.redis.get(_prefixed_key(key))
    end

    def []=(k, v)
      Lit.redis.set(_prefixed_key(k).to_s, v.to_s)
    end

    def delete(k)
      Lit.redis.del k
    end

    def clear
      Lit.redis.del(self.keys) if self.keys.length > 0
    end

    def keys
      Lit.redis.keys(_prefixed_key+"*")
    end

    def has_key?(key)
      Lit.redis.exists(_prefixed_key(key))
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
      def _prefixed_key(key="")
        prefix = "lit:"
        if Lit.storage_options.is_a?(Hash)
          prefix += "#{Lit.storage_options[:prefix]}:" if Lit.storage_options.has_key?(:prefix)
        end
        prefix+key
      end
  end
end