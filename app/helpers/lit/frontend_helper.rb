module Lit
  module FrontendHelper
    include ActionView::Helpers::TranslationHelper
    module TranslationKeyWrapper
      def translate(key, options = {})
        options = options.with_indifferent_access
        key = scope_key_by_partial(key)
        ret = super(key, options)
        if !options[:skip_lit] && lit_authorized?
          ret = content_tag :span,
                            class: 'lit-key-generic',
                            data: { key: key, locale: I18n.locale } do
            ret
          end
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

    def lit_authorized?
      if Lit.authentication_verification.present?
        send(Lit.authentication_verification)
      else
        true
      end
    end
  end
end
