require 'i18n'

module Lit
  class I18nBackend
    include I18n::Backend::Simple::Implementation

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
      Lit::Locale.ordered.visible.all.map{|l| l.locale.to_sym }
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

      unless @cache.has_key?(key_with_locale)
        @cache.init_key_with_value(key_with_locale, content)
        content = @cache[key_with_locale]
      end
      ## store value if not found - updating in DB would always return '' (empty
      ## string), so we can safely assume, that possible default has bigger
      ## "priority"
      if content.nil?
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
        @cache[key] = data
      end
    end

    def load_translations(*filenames)
      super
      @cache.load_all_translations
    end

    def default(locale, object, subject, options = {})
      content = super(locale, object, subject, options)
      if content.respond_to?(:to_str)
        parts = I18n.normalize_keys(locale, object, options[:scope], options[:separator])
        key = parts.join('.')
        @cache[key] = content
      end
      content
    end

    attr_reader :cache
  end
end
