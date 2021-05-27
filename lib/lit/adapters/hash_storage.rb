module Lit::Adapters
  class HashStorage < Hash
    def incr(key)
      self[key] ||= 0
      if self[key].is_a?(Integer)
        self[key] += 1
      else
        subtree_keys(key).each { |k| self[k] += 1 }
      end
    end

    def prefix
      nil
    end

    def [](key)
      super || subtree_of_key(key)
    end

    private

    def subtree_of_key(key)
      keys_of_subtree = subtree_keys(key)
      return nil if keys_of_subtree.empty?

      cache_localizations = form_cache_localizations(keys_of_subtree)

      full_subtree = Lit::Services::LocalizationKeysToHashService.call(cache_localizations)
      requested_part = full_subtree.dig(*key.split('.'))
      return nil if requested_part.blank?
      return requested_part if requested_part.is_a?(String)

      requested_part.deep_transform_keys(&:to_sym)
    end

    def subtree_keys(key)
      keys.select { |k| k.match?(/\A#{key}*/) }
    end

    def form_cache_localizations(keys_of_subtree)
      self_copy = self.select { |k, _| k.in?(keys_of_subtree) }
      values_of_subtree = keys_of_subtree.map { |k| self_copy[k] }
      Hash[keys_of_subtree.zip(values_of_subtree)]
    end
  end
end
