# frozen_string_literal: true

module Lit
  # Converts flat hash with localization_keys as keys and translations as values to nested hash
  # by nesting on '.' localization key dots
  class LocalizationKeysToHashService
    # http://subtech.g.hatena.ne.jp/cho45/20061122
    def self.call(db_localizations)
      deep_proc = proc do |_k, s, o|
        next s.merge(o, &deep_proc) if s.is_a?(Hash) && o.is_a?(Hash)

        next o
      end
      nested_keys = {}
      db_localizations.sort.each do |k, v|
        key_parts = k.to_s.split('.')
        converted = key_parts.reverse.reduce(v) { |a, n| { n => a } }
        nested_keys.merge!(converted, &deep_proc)
      end
      nested_keys
    end
  end
end
