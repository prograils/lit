module Lit
  class ApplicationController < ActionController::Base
    unless respond_to?(:before_action)
      alias_method :before_action, :before_filter
      alias_method :after_action, :after_filter
    end
    before_action :authenticate
    before_action :stop_hits_counter
    after_action :restore_hits_counter

    private

    def authenticate
      return unless Lit.authentication_function.present?

      send(Lit.authentication_function)
    end

    def stop_hits_counter
      Lit.init.cache.stop_hits_counter
    end

    def restore_hits_counter
      Lit.init.cache.restore_hits_counter
    end

    def redirect_to_back_or_default(fallback_location: lit.localization_keys_path)
      if respond_to?(:redirect_back)
        redirect_back fallback_location: fallback_location
      else
        if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
          redirect_to :back
        else
          redirect_to fallback_location
        end
      end
    end
  end
end
