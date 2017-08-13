module I18n
  class << self
    @@cache_store = nil

    def cache_store
      @@cache_store || I18n.backend.cache
    end

    def cache_store=(store)
      @@cache_store = store
    end

    def perform_caching?
      !cache_store.nil?
    end
  end
end

module Lit
  class Cache
    def initialize
      @hits_counter = Lit.get_key_value_engine
      @hits_counter_working = true
      @keys = nil
    end

    def [](key)
      update_hits_count(key)
      ret = localizations[key]
      ret
    end

    def []=(key, value)
      update_locale(key, value)
    end

    def init_key_with_value(key, value)
      update_locale(key, value, true)
    end

    def has_key?(key)
      localizations.has_key?(key)
    end

    def sync
      localizations.clear
    end

    def keys
      return @keys if @keys.present?
      @keys = localizations.keys
      return @keys if localizations.prefix.nil?
      @keys = @keys.map do |k|
        k.gsub(/^#{localizations.prefix}/, '')
      end
    end

    def update_locale(key, value, force_array = false, startup_process = false)
      key = key.to_s
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale, value, force_array, true)
      return localization.get_value if startup_process && localization.is_changed?
      localizations[key] = localization.get_value if localization
    end

    def update_cache(key, value)
      key = key.to_s
      localizations[key] = value
    end

    def delete_locale(key)
      key = key.to_s
      keys.delete(key)
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      delete_localization(locale, key_without_locale)
    end

    def load_all_translations
      first = Localization.order(id: :asc).first
      last = Localization.order(id: :desc).first
      if !first || (!localizations.has_key?(first.full_key) ||
        !localizations.has_key?(last.full_key))
        Localization.includes([:locale, :localization_key]).find_each do |l|
          localizations[l.full_key] = l.get_value
        end
      end
    end

    def refresh_key(key)
      key = key.to_s
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale)
      localizations[key] = localization.get_value if localization
    end

    def delete_key(key)
      key = key.to_s
      localizations.delete(key)
      key_without_locale = split_key(key).last
      localization_keys.delete(key_without_locale)
      I18n.backend.reload!
    end

    def reset
      @locale_cache = {}
      localizations.clear
      localization_keys.clear
      load_all_translations
    end

    alias_method :clear, :reset

    def find_locale(locale_key)
      locale_key = locale_key.to_s
      @locale_cache ||= {}
      unless @locale_cache.key?(locale_key)
        locale = Lit::Locale.where(locale: locale_key).first_or_create!
        @locale_cache[locale_key] = locale
      end
      @locale_cache[locale_key]
    end

    # this comes directly from copycopter.
    def export
      reset
      localizations_scope = Lit::Localization
      unless ENV['LOCALES'].blank?
        locale_keys = ENV['LOCALES'].to_s.split(',') || []
        locale_ids = Lit::Locale.where(locale: locale_keys).pluck(:id)
        localizations_scope = localizations_scope.where(locale_id: locale_ids) unless locale_ids.empty?
      end
      db_localizations = {}
      localizations_scope.find_each do |l|
        db_localizations[l.full_key] = l.get_value
      end
      exported_keys = nested_string_keys_to_hash(db_localizations)
      exported_keys.to_yaml
    end

    def nested_string_keys_to_hash(db_localizations)
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
        converted = key_parts.reverse.reduce(v) { |a, n| { n => a } }
        nested_keys.merge!(converted, &deep_proc)
      end
      nested_keys
    end

    def get_global_hits_counter(key)
      @hits_counter['global_hits_counter.' + key]
    end

    def get_hits_counter(key)
      @hits_counter['hits_counter.' + key]
    end

    def stop_hits_counter
      @hits_counter_working = false
    end

    def restore_hits_counter
      @hits_counter_working = true
    end

    private

    def localizations
      @localizations ||= Lit.get_key_value_engine
    end

    def localization_keys
      @localization_keys ||= Lit.get_key_value_engine
    end

    def find_localization(locale, key_without_locale, value = nil, force_array = false, update_value = false)
      unless value.is_a?(Hash)
        ActiveRecord::Base.transaction do
          localization_key = find_localization_key(key_without_locale)
          localization = Lit::Localization.where(locale_id: locale.id).
                            where(localization_key_id: localization_key.id).first_or_initialize
          if update_value || localization.new_record?
            if value.is_a?(Array)
              unless force_array
                new_value = nil
                value_clone = value.dup
                while (v = value_clone.shift) && v.present?
                  pv = parse_value(v, locale)
                  new_value = pv unless pv.nil?
                end
                value = new_value
              end
            else
              value = parse_value(value, locale) unless value.nil?
            end
            if value.nil?
              if fallbacks = ::Rails.application.config.i18n.fallbacks
                keys = fallbacks == true ? @locale_cache.keys : fallbacks
                keys.map(&:to_s).each do |lc|
                  if lc != locale.locale
                    nk = "#{lc}.#{key_without_locale}"
                    v = localizations[nk]
                    value = v if v.present? && value.nil?
                  end
                end
              end
            end
            localization.update_default_value(value)
          end
          return localization

        end
      else
        nil
      end
    end

    def find_localization_for_delete(locale, key_without_locale)
      localization_key = find_localization_key_for_delete(key_without_locale)
      return nil unless localization_key
      Lit::Localization.find_by(locale_id: locale.id,
                                localization_key_id: localization_key.id)
    end

    def delete_localization(locale, key_without_locale)
      localization = find_localization_for_delete(locale, key_without_locale)
      return unless localization
      localizations.delete("#{locale.locale}.#{key_without_locale}")
      localization_keys.delete(key_without_locale)
      localization.destroy # or localization.default_value = nil; localization.save!
    end

    ## checks parameter type and returns value basing on it
    ## symbols are beeing looked up in db
    ## string are returned directly
    ## procs are beeing called (once)
    ## hashes are converted do string (for now)
    def parse_value(v, locale)
      new_value = nil
      case v
        when Symbol then
          lk = Lit::LocalizationKey.where(localization_key: v.to_s).first
          if lk
            loca = Lit::Localization.where(locale_id: locale.id).
                        where(localization_key_id: lk.id).first
            new_value = loca.get_value if loca && loca.get_value.present?
          end
        when String then
          new_value = v
        when Hash then
          new_value = nil
        when Proc then
          new_value = nil # was v.call - requires more love
        else
          new_value = v.to_s
      end
      new_value
    end

    def find_localization_key(key_without_locale)
      unless localization_keys.key?(key_without_locale)
        find_or_create_localization_key(key_without_locale)
      else
        Lit::LocalizationKey.find_by(id: localization_keys[key_without_locale]) || find_or_create_localization_key(key_without_locale)
      end
    end

    def find_localization_key_for_delete(key_without_locale)
      lk = Lit::LocalizationKey.find_by(id: localization_keys[key_without_locale]) if localization_keys.has_key?(key_without_locale)
      lk || Lit::LocalizationKey.where(localization_key: key_without_locale).first
    end

    def split_key(key)
      Lit::Cache.split_key(key)
    end

    def find_or_create_localization_key(key_without_locale)
      localization_key = Lit::LocalizationKey.where(localization_key: key_without_locale).first_or_create!
      localization_keys[key_without_locale] = localization_key.id
      localization_key
    end

    def update_hits_count(key)
      if @hits_counter_working
        key_without_locale = split_key(key).last
        @hits_counter.incr('hits_counter.' + key)
        @hits_counter.incr('global_hits_counter.' + key_without_locale)
      end
    end

    def self.split_key(key)
      key.split('.', 2)
    end
  end
end
