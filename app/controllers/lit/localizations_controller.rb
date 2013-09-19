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
        Lit.init.cache.refresh_key @localization.full_key
      end
      @localization.reload
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
        if ::Rails::VERSION::MAJOR>=4
          params[:localization].permit(:translated_value, :locale_id)
        else
          params[:localization]
        end
      end
  end
end
