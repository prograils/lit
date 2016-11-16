module Lit
  module FrontendHelper
    include ActionView::Helpers::TranslationHelper
    def translate_with_lit(key, options = {})
      key = scope_key_by_partial(key)
      ret = translate_without_lit(key, options)
      if lit_authorized?
        ret = content_tag :span,
                          class: 'lit-key-generic',
                          data: { key: key, locale: I18n.locale } do
          ret
        end
      end
      ret
    end
    alias_method_chain :translate, :lit

    def t_with_lit(key, options = {})
      translate_with_lit(key, options)
    end
    alias_method_chain :t, :lit

    def javascript_lit_files
      javascript_include_tag 'lit/lit_frontend'
    end

    def stylesheet_lit_files
      stylesheet_link_tag 'lit/lit_frontend'
    end

    def lit_frontend_files
      return unless lit_authorized?
      meta = content_tag :meta,
                         '',
                         value: lit.find_localization_localization_keys_path,
                         name: 'lit-url-base'
      safe_join([javascript_lit_files, stylesheet_lit_files, meta])
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
