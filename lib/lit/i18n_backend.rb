require 'i18n'

module Lit
  class I18nBackend
    include I18n::Backend::Simple::Implementation

    attr_reader :cache

    def initialize(cache)
      @cache = cache
      @available_locales_cache = nil
    end

    def translate(locale, key, options = {})
      content = super(locale, key, options.merge(fallback: Lit.fallback))
      if Lit.all_translations_are_html_safe && content.respond_to?(:html_safe)
        content.html_safe
      else
        content
      end
    end

    def available_locales
      return @available_locales_cache unless @available_locales_cache.nil?
      locales = ::Rails.configuration.i18n.available_locales
      if locales && !locales.empty?
        @available_locales_cache = locales.map(&:to_sym)
      else
        @available_locales_cache = Lit::Locale.ordered.visible.map { |l| l.locale.to_sym }
      end
      @available_locales_cache
    end

    def reset_available_locales_cache
      @available_locales_cache = nil
    end

    # Stores the given translations.
    #
    # @param [String] locale the locale (ie "en") to store translations for
    # @param [Hash] data nested key-value pairs to be added as blurbs
    def store_translations(locale, data, options = {})
      super
      ActiveRecord::Base.transaction do
        store_item(locale, data)
      end if store_items? && valid_locale?(locale)
    end

    private

    def lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?

      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key_with_locale = parts.join('.')

      ## check in cache or in simple backend
      content = @cache[key_with_locale] || super
      return content if parts.size <= 1

      if should_cache?(key_with_locale)
        new_content = @cache.init_key_with_value(key_with_locale, content)
        content = new_content if content.nil? # Content can change when Lit.humanize is true for example

        if content.nil? && options[:default].present?
          if options[:default].is_a?(Array)
            default = options[:default].map do |key|
              if key.is_a?(Symbol)
                I18n.normalize_keys(nil, key.to_s, options[:scope], options[:separator]).join('.').to_sym
              else
                key
              end
            end
          else
            default = options[:default]
          end

          @cache[key_with_locale] = default
          content = @cache[key_with_locale]
        end
      end
      ## return translated content
      content
    end

    def store_item(locale, data, scope = [], unless_changed = false)
      if data.respond_to?(:to_hash)
        # ActiveRecord::Base.transaction do
          data.to_hash.each do |key, value|
            store_item(locale, value, scope + [key], unless_changed)
          end
        # end
      else
        key = ([locale] + scope).join('.')
        if data.respond_to?(:to_str)
          @cache.update_locale(key, data, false, unless_changed)
        elsif data.is_a?(Array)
          @cache.update_locale(key, data, true, unless_changed)
        elsif data.nil?
          key = ([locale] + scope).join('.')
          @cache.delete_locale(key, unless_changed)
        end
      end
    end

    def load_translations_to_cache
      ActiveRecord::Base.transaction do
        (@translations || {}).each do |locale, data|
          store_item(locale, data, [], true) if valid_locale?(locale)
        end
      end
    end

    def init_translations
      # Load all translations from *.yml, *.rb files to @translations variable.
      # We don't want to store translations in lit cache just yet. We'll do it
      # with `load_translations_to_cache` when all translations form yml (rb)
      # files will be loaded.
      without_store_items { load_translations }
      # load translations from database to cache
      @cache.load_all_translations
      # load translations from @translations to cache
      load_translations_to_cache
      @initialized = true
    end

    def without_store_items
      @store_items = false
      yield
    ensure
      @store_items = true
    end

    def store_items?
      @store_items.nil? || @store_items
    end

    def valid_locale?(locale)
      locales = ::Rails.configuration.i18n.available_locales
      !locales || locales.map(&:to_s).include?(locale.to_s)
    end

    def is_ignored_key(key_without_locale)
      Lit.ignored_keys.any?{ |k| key_without_locale.start_with?(k) }
    end

    def should_cache?(key_with_locale)
      return false if @cache.has_key?(key_with_locale)

      _, key_without_locale = ::Lit::Cache.split_key(key_with_locale)
      return false if is_ignored_key(key_without_locale)

      true
    end
  end
end
