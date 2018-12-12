module Lit
  class LocalizationsController < ::Lit::ApplicationController
    before_action :find_localization_key
    before_action :find_localization

    def show
      render json: { value: @localization.translation }
    end

    def edit
      @localization.translated_value = @localization.translation
      respond_to do |format|
        format.js
      end
    end

    def update
      # Wrapping it in a transaction leverages the fact that @localization's
      # :after_commit callback is then executed AFTER whatever's done in
      # #after_update_operations. So it'll first set :is_changed to true
      # and then it will be properly read in the cache setting routine.
      @localization.transaction do
        after_update_operations if @localization.update_attributes(clear_params)
      end
      respond_to do |f|
        f.js
        f.json do
          render json: { value: @localization.reload.translation }
        end
      end
    end

    def change_completed
      @localization.toggle(:is_changed).save!
      respond_to :js
    end

    def previous_versions
      @versions = @localization.versions.order(created_at: :desc)
      respond_to :js
    end

    private

    def find_localization_key
      @localization_key =
        Lit::LocalizationKey.active.find(params[:localization_key_id])
    end

    def find_localization
      @localization =
        @localization_key.localizations.includes(:locale).find(params[:id])
    end

    def after_update_operations
      @localization.update_column :is_changed, true
    end

    def clear_params
      if params.respond_to?(:permit)
        # allow translated_value to be an array
        if @localization.value.is_a?(Array)
          params.require(:localization).permit(:locale_id, translated_value: [])
        else
          params.require(:localization).permit(:locale_id, :translated_value)
        end
      else
        params[:localization].is_a?(Hash) ? params[:localization].slice(:translated_value, :locale_id) : {}
      end
    end
  end
end
