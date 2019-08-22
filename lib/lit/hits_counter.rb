# frozen_string_literal: true

module Lit
  class HitsCounter
    def incr(key_without_locale)
      store.incr("global_hits_counter.#{key_without_locale}")
    end

    def [](key_without_locale)
      store["global_hits_counter.#{key_without_locale}"]
    end

    def self.instance
      @instance ||= new
    end

    private

    def store
      @store ||= Lit.get_key_value_engine
    end
  end
end