class ApplicationController < ActionController::Base
  protect_from_forgery

  unless respond_to?(:before_action)
    alias_method :before_action, :before_filter
  end

  helper Lit::FrontendHelper

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end
end
