require 'redis'
module Lit
  class RedisStorage
    def initialize
      @r = ::Redis.new
    end

    def [](key)
      @r.get(key)
    end

    def []=(k, v)
      ret = @r.set(k, v.to_s)
      @r.save
      ret
    end

    def clear
      @r.flushall
      save
    end

    def keys
      @r.keys
    end

    def has_key?(key)
      @r.exists(key)
    end
  end
end