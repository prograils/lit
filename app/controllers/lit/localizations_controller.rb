module Lit
  class LocalizationsController < ::Lit::ApplicationController
    before_filter :find_localization_key
    before_filter :find_localization

    def edit
      @localization.translated_value = @localization.get_value
      respond_to :js
    end

    def update
      if @localization.update_attributes(clear_params)
        Lit.init.cache.update_cache @localization.full_key, @localization.get_value
      end
      @localization.reload
      respond_to :js
    end

    def previous_versions
      @versions = @localization.versions.order('created_at DESC')
      respond_to :js
    end

    private
      def find_localization_key
        @localization_key = Lit::LocalizationKey.find(params[:localization_key_id])
      end

      def find_localization
        @localization = @localization_key.localizations.find(params[:id])
      end

      def clear_params
        if defined?(::ActionController::StrongParameters)
          # allow translated_value to be an array
          if @localization.value.is_a?(Array)
            params.require(:localization).permit(:locale_id, :translated_value => [])
          else
            params.require(:localization).permit(:locale_id, :translated_value)
          end
        else
          params[:localization].is_a?(Hash) ? params[:localization].slice(:translated_value, :locale_id) : {}
        end
      end
  end
end
