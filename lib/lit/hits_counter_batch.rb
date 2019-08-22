# frozen_string_literal: true

module Lit
  class HitsCounterBatch
    def initialize
      @hits = []
    end

    def incr(key_without_locale)
      @hits << key_without_locale
    end

    def flush
      atomically do
        @hits.each do |key_without_locale|
          store.incr("global_hits_counter.#{key_without_locale}")
        end
      end
    end

    def [](key_without_locale)
      Lit::HitsCounter.instance[key_without_locale]
    end

    private

    def store
      @store ||= Lit.get_key_value_engine
    end

    def atomically(&block)
      if defined? Lit.redis
        Lit.redis.multi(&block)
      else
        yield
      end
    end
  end
end