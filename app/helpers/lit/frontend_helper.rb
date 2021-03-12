module Lit
  module FrontendHelper
    include ActionView::Helpers::TranslationHelper

    module TranslationKeyWrapper
      def translate(key, options = {})
        count = options[:count]
        options = options.with_indifferent_access
        key = scope_key_by_partial(key)
        key = pluralized_key(key, count) if count

        content = super(key, **options.symbolize_keys)
        if !options[:skip_lit] && lit_authorized?
          content = get_translateable_span(key, content)
        end
        content
      end

      def pluralized_key(key, count)
        pluralizer = I18n.backend.send(:pluralizer, locale)
        return unless pluralizer.respond_to?(:call)
        last = count.zero? ? :zero : pluralizer.call(count)
        format '%<key>s.%<last>s', key: key, last: last
      end

      def t(key, options = {})
        translate(key, options)
      end
    end
    prepend Lit::FrontendHelper::TranslationKeyWrapper

    def javascript_lit_tag
      javascript_include_tag 'lit/lit_frontend'
    end

    def stylesheet_lit_tag
      stylesheet_link_tag 'lit/lit_frontend'
    end

    def lit_frontend_assets
      return unless lit_authorized?
      meta = content_tag :meta,
                         '',
                         value: lit.find_localization_localization_keys_path,
                         name: 'lit-url-base'
      safe_join [javascript_lit_tag, stylesheet_lit_tag, meta]
    end

    def lit_translations_info
      return if Thread.current[:lit_request_keys].nil?
      return unless lit_authorized?
      content_tag :div, class: 'lit-translations-info collapsed' do
        concat content_tag(:span, 'Show translations', class: 'lit-open-button')
        concat content_tag(:span, 'X', class: 'lit-close-button')
        concat translations_list_content_tag
      end
    end

    def translations_list_content_tag
      content_tag :ul, class: 'lit-translations-list' do
        Lit.init.cache.request_keys.each do |k, v|
          concat(content_tag(:li) do
            concat content_tag(:code, "#{k}:")
            concat get_translateable_span(k, v, alternative_text: '[empty]')
          end)
        end
      end
    end

    def lit_authorized?
      return false if Lit.authentication_verification.blank?
      send Lit.authentication_verification
    end

    def get_translateable_span(key, localization, alternative_text: nil)
      content_tag :span,
                  class: 'lit-key-generic',
                  data: { key: key, locale: I18n.locale } do
        localization.blank? ? alternative_text : localization
      end
    end
  end
end
