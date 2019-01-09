module Lit
  module LocalizationsHelper
    def draw_icon(icon, opts = {})
      raw "<i class=\"fa fa-#{icon} #{opts[:class]}\" " \
          "title=\"#{opts[:title]}\" ></i>"
    end

    def ejs(val)
      escape_javascript val.to_s
    end

    def allow_wysiwyg_editor?(key)
      Lit.all_translations_are_html_safe || key.to_s =~ /(\b|_|\.)html$/
    end

    def available_locales_with_default_first
      I18n.available_locales.sort_by { |l| l == I18n.default_locale ? 0 : 1 }
    end
  end
end
