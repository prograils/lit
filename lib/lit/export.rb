require 'csv'

module Lit
  class Export
    def self.call(locale_keys:, format:, include_hits_count: false)
      raise ArgumentError, "format must be yaml, json_js or csv" if %i[json_js yaml csv].exclude?(format)
      Lit.loader.cache.load_all_translations
      localizations_scope = Lit::Localization.active
      if locale_keys.present?
        locale_ids = Lit::Locale.where(locale: locale_keys).pluck(:id)
        localizations_scope = localizations_scope.where(locale_id: locale_ids) unless locale_ids.empty?
      end
      db_localizations = {}
      localizations_scope.find_each do |l|
        db_localizations[l.full_key] = l.translation
      end

      case format
      when :yaml
        exported_keys = nested_string_keys_to_hash(db_localizations)
        exported_keys.to_yaml
      when :json_js
        exported_keys = nested_string_keys_to_hash(db_localizations, "javascript")
        exported_keys.to_json
       when :csv
        relevant_locales = locale_keys.presence || I18n.available_locales.map(&:to_s)
        CSV.generate do |csv|
          csv << ['key', *relevant_locales, ('hits' if include_hits_count)].compact
          keys_without_locales = db_localizations.keys.map { |k| k.gsub(/(#{relevant_locales.join('|')})\./, '') }.uniq
          keys_without_locales.each do |key_without_locale|
            # Here, we need to determine if we're dealing with an array or a scalar.
            # In the former case, for simplicity of editing (which is likely the main
            # intent when exporting translations to CSV), let's make the "array" be simulated
            # as a number of consecutive rows that have the same key.
            #
            # For example:
            #
            # key,en
            # date.abbr_month_names,     <-- in this case it's empty because that array has nothing at [0]
            # date.abbr_month_names,Jan
            # date.abbr_month_names,Feb
            # date.abbr_month_names,Mar
            # date.abbr_month_names,Apr
            # date.abbr_month_names,May
            # ...

            key_localizations_per_locale =
              relevant_locales.map { |l| Array.wrap(db_localizations["#{l}.#{key_without_locale}"]) }
            transpose(key_localizations_per_locale).each do |translation_series|
              csv_row = [key_without_locale, *translation_series]
              if include_hits_count
                csv_row << (Lit.init.cache.get_global_hits_counter(key_without_locale) || 0)
              end
              csv << csv_row
            end
          end
        end
      end
    end

    private_class_method def self.nested_string_keys_to_hash(db_localizations, key_selector=nil)
      # http://subtech.g.hatena.ne.jp/cho45/20061122
      deep_proc = proc do |_k, s, o|
        if s.is_a?(Hash) && o.is_a?(Hash)
          next s.merge(o, &deep_proc)
        end
        next o
      end
      nested_keys = {}
      db_localizations.sort.each do |k, v|
        key_parts = k.to_s.split('.')
        if (key_selector.present? && key_parts[1] == key_selector) || key_selector.nil?
          key_parts.drop(2) if key_selector.present? 
          converted = key_parts.reverse.reduce(v) { |a, n| { n => a } }
          nested_keys.merge!(converted, &deep_proc)
        end
      end
      if key_selector.present?
        "var js_locale= #{nested_keys}"
      else
        nested_keys
      end
    end

    # This is like Array#transpose but ignores size differences between inner arrays.
    private_class_method def self.transpose(matrix)
      maxlen = matrix.max { |x| x.length }.length
      matrix.each do |array|
        array[maxlen - 1] = nil if array.length < maxlen
      end
      matrix.transpose
    end
  end
end
