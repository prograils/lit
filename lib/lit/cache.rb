module Lit
  class Cache

    def initialize
      @localizations = Lit.get_key_value_engine
      @hits_counter = Lit.get_key_value_engine
      @hits_counter_working = true
    end

    def [](key)
      update_hits_count(key)
      @localizations[key] 
    end

    def []=(key, value)
      update_locale(key, value)
    end

    def sync
      @localizations.clear
    end

    def keys
      @localizations.keys
    end

    def update_locale(key, value)
      key = key.to_s
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale, value)
      @localizations[key] = localization.get_value if localization
    end

    def load_all_translations(oninit=false)
      Lit.init.logger.info "loading all translations"
      doinit = false
      first = Localization.order('id ASC').first
      last = Localization.order('id DESC').first
      if not first or not last or (not @localizations.has_key?(first.full_key) or
        not @localizations.has_key?(last.full_key))
        doinit = true
      end

      if oninit==false || doinit==true
        Localization.includes([:locale, :localization_key]).find_each do |l|
          @localizations[l.full_key] = l.get_value
        end
      end
    end

    def refresh_key(key)
      key = key.to_s
      Lit.init.logger.info "refreshing key: #{key}"
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale)
      @localizations[key] = localization.get_value if localization
    end

    def delete_key(key)
      key = key.to_s
      Lit.init.logger.info "deleting key: #{key}"
      @localizations.delete(key)
      locale_key, key_without_locale = split_key(key)
      @localization_keys.delete(key_without_locale)
      I18n.backend.reload!
    end

    def reset
      @locale_cache = {}
      @localizations = Lit.get_key_value_engine
      @localizations.clear
      @localization_keys = Lit.get_key_value_engine
      @localization_keys.clear
      load_all_translations
    end

    def find_locale(locale_key)
      locale_key = locale_key.to_s
      @locale_cache ||= {}
      unless @locale_cache.has_key?(locale_key)
        #Lit.init.logger.info "looking for locale: #{locale_key}"
        locale = Lit::Locale.where(:locale=>locale_key).first_or_create!
        @locale_cache[locale_key] = locale
      end
      @locale_cache[locale_key]
    end


    # this comes directly from copycopter.
    def export
      keys = {}
      reset
      db_localizations = {}
      Lit::Localization.find_each do |l|
        db_localizations[l.full_key] = l.get_value
      end
      db_localizations.sort.each do |(l_key, value)|
        current = keys
        yaml_keys = l_key.split('.')

        0.upto(yaml_keys.size - 2) do |i|
          key = yaml_keys[i]
          # Overwrite en.key with en.sub.key
          unless current[key].class == Hash
            current[key] = {}
          end
          current = current[key]
        end
        current[yaml_keys.last] = value
      end
      keys.to_yaml
    end

    def get_global_hits_counter(key)
      @hits_counter['global_hits_counter.'+key]
    end

    def get_hits_counter(key)
      @hits_counter['hits_counter.'+key]
    end

    def stop_hits_counter
      @hits_counter_working = false
    end

    def restore_hits_counter
      @hits_counter_working = true
    end

    private

      def find_localization(locale, key_without_locale, value=nil)
        org_value = value.present? ? value.dup : nil
        unless value.is_a?(Hash)
          localization_key = find_localization_key(key_without_locale)
          localization = Lit::Localization.where(:locale_id=>locale.id).
                            where(:localization_key_id=>localization_key.id).first_or_create do |l|
            if value.is_a?(Array)
              new_value = nil
              value_clone = value.dup
              while (v = value_clone.pop) && v.present?
                pv = parse_value(v, locale)
                new_value = pv unless pv.nil?
              end
              value = new_value
            else
              value = parse_value(value, locale) if value
            end
            if value.nil?
              if Lit.fallback
                @locale_cache.keys.each do |lc|
                  if lc != locale.locale
                    nk = "#{lc}.#{key_without_locale}"
                    v = @localizations[nk]
                    value = v if v.present? and value.nil?
                  end
                end
              end
              value = key_without_locale.split('.').last.humanize if value.nil?
            end
            l.default_value = value
          end
          localization
        else
          Lit.init.logger.info "returning value for hash: #{key_without_locale}: #{value.to_s}"
          nil
        end
      end

      ## checks parameter type and returns value basing on it
      ## symbols are beeing looked up in db
      ## string are returned directly
      ## procs are beeing called (once)
      ## hashes are converted do string (for now)
      def parse_value(v, locale)
        new_value = nil
        case v.class
          when Symbol then
            lk = Lit::LocalizationKey.where(:localization_key=>v.to_s).first
            if lk
              loca = Lit::Localization.where(:locale_id=>locale.id).
                          where(:localization_key_id=>lk.id).first
              new_value = loca.get_value if loca and loca.get_value.present?
            end
          when String then
            new_value = v
          when Proc then
            new_value = v.call
          else
            new_value = v.to_s
        end
        new_value
      end

      def find_localization_key(key_without_locale)
        @localization_keys ||= Lit.get_key_value_engine
        unless @localization_keys.has_key?(key_without_locale)
          find_or_create_localization_key(key_without_locale)
        else
          localization_key = Lit::LocalizationKey.find_by_id(@localization_keys[key_without_locale]) || find_or_create_localization_key(key_without_locale)
        end
      end

      def split_key(key)
        key_split = key.split('.')
        locale_key = key_split.first
        key_without_locale = key_split[1..-1].join('.')
        [locale_key, key_without_locale]
      end

      def find_or_create_localization_key(key_without_locale)
        #Lit.init.logger.info "creating key: #{key_without_locale} with id #{localization_key.id}"
        localization_key = Lit::LocalizationKey.where(:localization_key=>key_without_locale).first_or_create! 
        @localization_keys[key_without_locale] = localization_key.id
        localization_key
      end

      def update_hits_count(key)
        if @hits_counter_working 
          _lo_key, key_without_locale = split_key(key)
          @hits_counter.incr('hits_counter.'+key)
          @hits_counter.incr('global_hits_counter.'+key_without_locale)
        end
      end

  end
end
