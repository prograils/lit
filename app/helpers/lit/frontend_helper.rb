module Lit
  module FrontendHelper
    include ActionView::Helpers::TranslationHelper
    module TranslationKeyWrapper
      def translate(key, options = {})
        options = options.with_indifferent_access
        key = scope_key_by_partial(key)
        ret = super(key, options)
        if !options[:skip_lit] && lit_authorized?
          ret = get_translateable_span(key, ret)
        end
        ret
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
      safe_join([javascript_lit_tag, stylesheet_lit_tag, meta])
    end

    def lit_translations_info
      return if Thread.current[:lit_request_keys].nil?
      return unless lit_authorized?
      content_tag :div, class: 'lit-translations-info collapsed' do
        concat content_tag :span, 'Show translations', class: 'lit-open-button'
        concat content_tag :span, 'X', class: 'lit-close-button'
        concat(content_tag(:ul, class: 'lit-translations-list') do
          Lit.init.cache.request_keys.each do |k, v|
            concat(content_tag(:li) do
              concat content_tag :code, "#{k}:"
              concat get_translateable_span(k, v, alternative_text: '[empty]')
            end)
          end
        end)
      end
    end

    def lit_authorized?
      if Lit.authentication_verification.present?
        send(Lit.authentication_verification)
      else
        true
      end
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
