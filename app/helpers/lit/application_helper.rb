module Lit
  module ApplicationHelper
    def draw_icon(icon, opts = {})
      raw("<i class=\"fa fa-#{icon} #{opts[:class]}\" title=\"#{opts[:title]}\" ></i>")
    end
  end
end
