require 'i18n'

module Lit
  class I18nBackend
    include I18n::Backend::Simple::Implementation

    attr_reader :cache

    def initialize(cache)
      @cache = cache
    end

    def translate(locale, key, options = {})
      content = super(locale, key, options.merge(:fallback => true))
      if content.respond_to?(:html_safe)
        content.html_safe
      else
        content
      end
    end

    def available_locales
      Lit::Locale.ordered.visible.map{|l| l.locale.to_sym }
    end

    # Stores the given translations.
    #
    # @param [String] locale the locale (ie "en") to store translations for
    # @param [Hash] data nested key-value pairs to be added as blurbs
    def store_translations(locale, data, options = {})
      super
      store_item(locale, data)
    end


    private

    def lookup(locale, key, scope = [], options = {})
      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key_with_locale = parts.join('.')

      ## check in cache or in simple backend
      content = @cache[key_with_locale] || super
      return content if parts.size <= 1

      newly_created = false
      unless @cache.has_key?(key_with_locale)
        @cache.init_key_with_value(key_with_locale, content)
        newly_created = true
      end
      if content.nil? || (newly_created && options[:default].present?)
        @cache[key_with_locale] = options[:default]
        content = @cache[key_with_locale]
      end
      ## return translated content
      content
    end

    def store_item(locale, data, scope = [])
      if data.respond_to?(:to_hash)
        data.to_hash.each do |key, value|
          store_item(locale, value, scope + [key])
        end
      elsif data.respond_to?(:to_str)
        key = ([locale] + scope).join('.')
        @cache[key] ||= data
      elsif data.nil?
        key = ([locale] + scope).join('.')
        @cache.delete_locale(key)
      end
    end

    def load_translations(*filenames)
      @cache.load_all_translations
      super
    end

  end
end
