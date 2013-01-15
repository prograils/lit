module Lit
  class Cache

    def initialize
      @localizations = Lit.get_key_value_engine
    end

    def [](key)
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
      locale_key, key_without_locale = split_key(key)
      #Lit.init.logger.info "key: #{key}"
      #Lit.init.logger.info "key_without_locale: #{key_without_locale}"
      #Lit.init.logger.info "value: #{value}"
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale, value)
      @localizations[key] = localization.get_value
    end

    def load_all_translations
      Lit.init.logger.info "loading all translations"
      Localization.includes([:locale, :localization_key]).find_each do |l|
        @localizations[l.full_key] = l.get_value
      end
    end

    def refresh_key(key)
      Lit.init.logger.info "refreshing key: #{key}"
      locale_key, key_without_locale = split_key(key)
      locale = find_locale(locale_key)
      localization = find_localization(locale, key_without_locale)
      @localizations[key] = localization.get_value
    end

    def delete_key(key)
      Lit.init.logger.info "deleting key: #{key}"
      @localizations.delete(key)
      locale_key, key_without_locale = split_key(key)
      @localization_keys.delete(key_without_locale)
      I18n.backend.reload!
    end

    def reset
      @locale_cache = {}
      @localizations = Lit.get_key_value_engine
      @localization_keys = Lit.get_key_value_engine
      load_all_translations
    end

    def find_locale(locale_key)
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
      @localizations.sort.each do |(l_key, value)|
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

    private

      def find_localization(locale, key_without_locale, value=nil)
        localization_key = find_localization_key(key_without_locale)
        create = false
        localization = Lit::Localization.where(:locale_id=>locale.id).
                          where(:localization_key_id=>localization_key.id).first_or_create do |l|
          if value.is_a?(Array)
            if value.length > 1
              new_value = nil
              value_clone = value.dup
              while v = value_clone.pop
                lk = Lit::LocalizationKey.where(:localization_key=>v).first
                if lk
                  loca = Lit::Localization.where(:locale_id=>locale.id).
                              where(:localization_key_id=>lk.id).first
                  new_value = loca.get_value if loca and loca.get_value.present?

                end
              end
              value = new_value.nil? ? value.last : new_value
            else
              value = value.first
            end
          end
          l.default_value = value
          #Lit.init.logger.info "creating new localization: #{key_without_locale}"
          #Lit.init.logger.info "creating new localization with value: #{value}"
          #Lit.init.logger.info "creating new localization with value: #{value.class}"
          create = true
        end
        localization_key.clone_localizations if create and localization_key.localizations.count(:id)==1
        localization
      end

      def find_localization_key(key_without_locale)
        @localization_keys ||= Lit.get_key_value_engine
        unless @localization_keys.has_key?(key_without_locale)
          localization_key = Lit::LocalizationKey.where(:localization_key=>key_without_locale).first_or_create!
          @localization_keys[key_without_locale] = localization_key.id
          #Lit.init.logger.info "creating key: #{key_without_locale} with id #{localization_key.id}"
          localization_key
        else
          #Lit.init.logger.info "current keys: #{@localization_keys.keys}"
          #Lit.init.logger.info "And I was looking for key: #{key_without_locale}"
          #Lit.init.logger.info "And store has currently #{@localization_keys[key_without_locale]}"
          #Lit.init.logger.info Lit::LocalizationKey.all
          Lit::LocalizationKey.find(@localization_keys[key_without_locale])
        end
      end

      def split_key(key)
        key_split = key.split('.')
        locale_key = key_split.first
        key_without_locale = key_split[1..-1].join('.')
        [locale_key, key_without_locale]
      end

  end
end
