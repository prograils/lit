require 'i18n'

module Lit
  class I18nBackend
    include I18n::Backend::Simple::Implementation
    include I18n::Backend::Pluralization

    attr_reader :cache

    def initialize(cache)
      @cache = cache
      @available_locales_cache = nil
      @translations = {}
      reserved_keys = I18n.const_get(:RESERVED_KEYS) + %i[lit_default_copy]
      I18n.send(:remove_const, :RESERVED_KEYS)
      I18n.const_set(:RESERVED_KEYS, reserved_keys.freeze)
    end

    def translate(locale, key, options = {})
      options[:lit_default_copy] = options[:default].dup if can_dup_default(options)
      content = super(locale, key, options)
      if Lit.all_translations_are_html_safe && content.respond_to?(:html_safe)
        content.html_safe
      else
        content
      end
    end

    def available_locales
      return @available_locales_cache unless @available_locales_cache.nil?
      @locales ||= ::Rails.configuration.i18n.available_locales
      if @locales && !@locales.empty?
        @available_locales_cache = @locales.map(&:to_sym)
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

    def can_dup_default(options = {})
      return false unless options.key?(:default)
      return true if options[:default].is_a?(String)
      return true if options[:default].is_a?(Array) && \
                     (options[:default].first.is_a?(String) || \
                      options[:default].first.is_a?(Symbol) || \
                      options[:default].first.is_a?(Array))
      false
    end

    def lookup(locale, key, scope = [], options = {})
      init_translations unless initialized?

      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key_with_locale = parts.join('.')
      # check in cache or in simple backend
      content = @cache[key_with_locale] || super
      return content if parts.size <= 1

      if content.nil? && should_cache?(key_with_locale, options)
        new_content = @cache.init_key_with_value(key_with_locale, content)
        content = new_content if content.nil? # Content can change when Lit.humanize is true for example
        # so there is no content in cache - it might not be if ie. we're doing
        # fallback to already existing language
        if content.nil?
          # check if default was provided
          if options[:lit_default_copy].present?
            # default most likely will be an array
            if options[:lit_default_copy].is_a?(Array)
              default = options[:lit_default_copy].map do |key_or_value|
                if key_or_value.is_a?(Symbol)
                  I18n.normalize_keys(nil, key_or_value.to_s, options[:scope], options[:separator]).join('.').to_sym
                else
                  key_or_value
                end
              end
              default = default.first if default.is_a?(Array)
            else
              default = options[:lit_default_copy]
            end
            content = default
          end
          # if we have content now, let's store it in cache
          if content.present?
            @cache[key_with_locale] = content
            content = @cache[key_with_locale]
          end
          # content might be nil - default value passed to cache was in fact
          # useless.
          # if content is still nil, we may try to humanize it. Rails will do
          # it anyway if we return nil, but then it will wrap it also in
          # translation_missing span.
          # Humanizing key should be last resort
          if content.nil? && Lit.humanize_key && key.match(Lit.humanize_key_ignored).nil?
            content = key.to_s.split('.').last.humanize
            if content.present?
              @cache[key_with_locale] = content
              content = @cache[key_with_locale]
            end
          end
        end
      end
      # return translated content
      content
    end

    def store_item(locale, data, scope = [], startup_process = false)
      key = ([locale] + scope).join('.')
      if data.respond_to?(:to_hash)
        # ActiveRecord::Base.transaction do
          data.to_hash.each do |k, value|
            store_item(locale, value, scope + [k], startup_process)
          end
        # end
      elsif data.respond_to?(:to_str) || data.is_a?(Array)
        key = ([locale] + scope).join('.')
        return if startup_process && @cache.keys.member?(key) && Lit.ignore_yaml_on_startup
        @cache.update_locale(key, data, data.is_a?(Array), startup_process)
      elsif data.nil?
        return if startup_process
        key = ([locale] + scope).join('.')
        @cache.delete_locale(key)
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
      !instance_variable_defined?(:@store_items) || @store_items
    end

    def valid_locale?(locale)
      @locales ||= ::Rails.configuration.i18n.available_locales
      !@locales || @locales.map(&:to_s).include?(locale.to_s)
    end

    def is_ignored_key(key_without_locale)
      Lit.ignored_keys.any?{ |k| key_without_locale.start_with?(k) }
    end

    def should_cache?(key_with_locale, options)
      if @cache.has_key?(key_with_locale)
        return false unless options[:default] && !options[:default].is_a?(Array)
      end

      _, key_without_locale = ::Lit::Cache.split_key(key_with_locale)
      return false if is_ignored_key(key_without_locale)

      true
    end
  end
end
