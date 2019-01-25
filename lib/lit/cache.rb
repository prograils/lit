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
      @request_info_store = Lit.get_key_value_engine
      @hits_counter_working = true
      @keys = nil
      @localization_object_cache = {}
      @localization_key_object_cache = {}
    end

    def [](key)
      key_without_locale = split_key(key).last
      update_hits_count(key)
      store_request_info(key_without_locale)
      localization = localizations[key]
      update_request_keys(key_without_locale, localization)
      localization
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
      localization = find_localization(locale, key_without_locale, value: value, force_array: force_array, update_value: true)
      return localization.translation if startup_process && localization.is_changed?
      localizations[key] = localization.translation if localization
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
      @localization_key_object_cache = {}
      @localization_object_cache = {}
    end

    def load_all_translations
      first = Localization.active.order(id: :asc).first
      last = Localization.active.order(id: :desc).first
      if !first || (!localizations.has_key?(first.full_key) ||
        !localizations.has_key?(last.full_key))
        Localization.includes(%i[locale localization_key]).active.find_each do |l|
          localizations[l.full_key] = l.translation
        end
      end
    end

    def refresh_key(key)
      key = key.to_s
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      @localization_object_cache.delete(key)
      localization = find_localization(locale, key_without_locale, default_fallback: true)
      localizations[key] = localization.translation if localization
    end

    def delete_key(key)
      key = key.to_s
      localizations.delete(key)
      key_without_locale = split_key(key).last
      localization_keys.delete(key_without_locale)
      @localization_object_cache.delete(key)
      @localization_key_object_cache.delete(key_without_locale)
      I18n.backend.reload!
    end

    def reset_local_cache
      @locale_cache = {}
      @localization_key_object_cache = {}
      @localization_object_cache = {}
    end

    def reset
      reset_local_cache
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

    def find_localization(locale, key_without_locale, value: nil, force_array: false, update_value: false, default_fallback: false)
      return nil if value.is_a?(Hash)
      full_key = "#{locale}.#{key_without_locale}"
      ActiveRecord::Base.transaction do
        localization_key = find_localization_key(key_without_locale)
        localization = @localization_object_cache[full_key]
        localization ||=
          Lit::Localization.where(locale_id: locale.id)
                           .where(localization_key_id: localization_key.id)
                           .first_or_initialize
        if update_value || localization.new_record?
          if value.is_a?(Array)
            value = parse_array_value(value, locale) unless force_array
          elsif !value.nil?
            value = parse_value(value, locale)
          else
            if ::Rails.application.config.i18n.fallbacks
              value = fallback_localization(locale, key_without_locale)
            elsif default_fallback
              value = fallback_to_default(localization_key, localization)
            end
          end
          # Prevent overwriting existing default value with nil.
          # However, if the localization record is #new_record?, we still need
          # to insert it with an empty default value.
          localization.locale = locale
          localization.localization_key = localization_key
          localization.full_key_str = full_key
          localization.update_default_value(value) if localization.new_record? || value
          @localization_object_cache[full_key] = localization
        end
        localization
      end
    end

    # fallback to translation in different locale
    def fallback_localization(locale, key_without_locale)
      value = nil
      return nil unless fallbacks = ::Rails.application.config.i18n.fallbacks
      keys = fallbacks == true ? @locale_cache.keys : fallbacks
      keys.map(&:to_s).each do |lc|
        if lc != locale.locale && value.nil?
          nk = "#{lc}.#{key_without_locale}"
          v = localizations[nk]
          value = v if v.present? && value.nil?
        end
      end
      value
    end

    # tries to get `default_value` from localization_key - checks other
    # localizations
    def fallback_to_default(localization_key, localization)
      localization_key.localizations.where.not(default_value: nil). \
        where.not(id: localization.id).first&.default_value
    end

    def find_localization_for_delete(locale, key_without_locale)
      localization_key = find_localization_key_for_delete(key_without_locale)
      return nil unless localization_key
      Lit::Localization.active.find_by(locale_id: locale.id,
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
          lk = @localization_key_object_cache[v.to_s] || \
            Lit::LocalizationKey.where(localization_key: v.to_s).first
          if lk
            loca = Lit::Localization.active.where(locale_id: locale.id).
                        where(localization_key_id: lk.id).first
            new_value = loca.translation if loca && loca.translation.present?
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

    def parse_array_value(value, locale)
      new_value = nil
      value_clone = value.dup
      while (v = value_clone.shift) && v.present?
        pv = parse_value(v, locale)
        new_value = pv unless pv.nil?
      end
      new_value
    end

    def find_localization_key(key_without_locale)
      return @localization_key_object_cache[key_without_locale] if @localization_key_object_cache.key?(key_without_locale)
      @localization_key_object_cache[key_without_locale] = if localization_keys.key?(key_without_locale)
                                                             Lit::LocalizationKey.find_by(
                                                               id: localization_keys[key_without_locale]
                                                             ) || find_or_create_localization_key(key_without_locale)
                                                           else
                                                             find_or_create_localization_key(key_without_locale)
                                                           end
      @localization_key_object_cache[key_without_locale]
    end

    def find_localization_key_for_delete(key_without_locale)
      return @localization_key_object_cache[key_without_locale] if @localization_key_object_cache.key?(key_without_locale)
      lk = Lit::LocalizationKey.find_by(id: localization_keys[key_without_locale]) if localization_keys.has_key?(key_without_locale)
      lk || Lit::LocalizationKey.where(localization_key: key_without_locale).first
    end

    def split_key(key)
      Lit::Cache.split_key(key)
    end

    def find_or_create_localization_key(key_without_locale)
      localization_key = Lit::LocalizationKey.find_or_initialize_by(
        localization_key: key_without_locale
      )
      localization_key.is_visited_again = true if localization_key.is_deleted?
      localization_key.save! if localization_key.changed?
      localization_keys[key_without_locale] = localization_key.id
      localization_key
    end

    def update_hits_count(key)
      return unless @hits_counter_working
      key_without_locale = split_key(key).last
      @hits_counter.incr('hits_counter.' + key)
      @hits_counter.incr('global_hits_counter.' + key_without_locale)
    end

    def store_request_info(key_without_locale)
      return unless Lit.store_request_info
      return unless Thread.current[:lit_current_request_path].present?
      info = get_request_info(key_without_locale)
      parts = info.split(' ').push(Thread.current[:lit_current_request_path]).uniq
      parts.shift if parts.count > 10
      @request_info_store['request_info.' + key_without_locale] = parts.join ' '
    end

    def update_request_keys(key_without_locale, localization)
      return if Thread.current[:lit_request_keys].nil?
      Thread.current[:lit_request_keys] ||= {}
      Thread.current[:lit_request_keys][key_without_locale] = localization
    end

    def request_keys
      Thread.current[:lit_request_keys] || {}
    end
    public :request_keys

    def get_request_info(key_without_locale)
      @request_info_store['request_info.' + key_without_locale].to_s
    end
    public :get_request_info

    def self.split_key(key)
      key.split('.', 2)
    end

    def self.flatten_hash(hash_to_flatten, parent = [])
      hash_to_flatten.flat_map do |key, value|
        case value
        when Hash then flatten_hash(value, parent + [key])
        else [(parent + [key]).join('.'), value]
        end
      end
    end
  end
end
