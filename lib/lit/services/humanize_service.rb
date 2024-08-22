# frozen_string_literal: true

module Lit
  module Services
    # Checks if should humanize based on config and blacklist.
    # Performs humanize if required
    # Caches the value of humanization
    class HumanizeService
      def self.should_humanize?(key)
        Lit.store_humanized_key && Lit.humanize_key_ignored.match(key).nil?
      end

      def self.humanize(key)
        key.to_s.split(".").last.humanize.titleize
      end

      def self.humanize_and_cache(key, options)
        content = humanize(key)
        parts = I18n.normalize_keys(
          options[:locale] || I18n.locale, key, options[:scope], options[:separator]
        )
        key_with_locale = parts.join(".")
        I18n.cache_store[key_with_locale] = content
        I18n.cache_store[key_with_locale]
      end
    end
  end
end
