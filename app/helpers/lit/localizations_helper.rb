module Lit
  module LocalizationsHelper
    def draw_icon(icon, opts={})
      raw("<i class=\"icon-#{icon} #{opts[:class]}\" title=\"#{opts[:title]}\" ></i>")
    end

    def ejs(val)
      escape_javascript val.to_s
    end
  end
end