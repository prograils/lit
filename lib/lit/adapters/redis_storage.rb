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
    attr_accessor :deferring, :in_multi

    def initialize
      Lit.redis
    end

    def [](key)
      return "___lit___#{key}___" if deferring
      return Lit.redis.get(_prefixed_key(key)) if in_multi

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
      Lit.redis.exists(_prefixed_key(key))
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

    def defer(original_content_proc:, replacement_proc:)
      self.deferring = true
      original = original_content_proc.call
      self.deferring = false
      replaced = deferred_load_values(original)
      replacement_proc.call(replaced)
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

    def atomically(&block)
      Lit.redis.multi(&block)
    end

    def deferred_load_values(response_body)
      keys = response_body.scan(/___lit___(.+)___/).flatten

      array_keys =
        keys.zip(
          Lit.redis.mget(
            *keys.map { |k| _prefixed_key_for_array(k) }
          )
        ).select { |pair| pair.second }.map { |pair| pair.first }

      non_array_keys = keys - array_keys

      self.in_multi = true

      non_array_values = atomically do
        non_array_keys.each do |key|
          self[key]
        end
      end

      self.in_multi = false

      array_values = array_keys.map { |k| self[k] }

      loaded = (array_keys.zip(array_values) + non_array_keys.zip(non_array_values)).to_h

      ret = response_body.clone
      loaded.each do |key, value|
        ret.gsub!("___lit___#{key}___", value)
      end
      ret
    end
  end
end
