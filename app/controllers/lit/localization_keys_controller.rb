module Lit
  class LocalizationKeysController < ApplicationController
    def index
      @q = LocalizationKey.search(params[:q])
      @localization_keys = @q.result.page(params[:page])
    end

    def destroy
      @localization_key = LocalizationKey.find params[:id]
      @localization_key.destroy
      I18n.backend.available_locales.each do |l|
        Lit.init.cache.delete_key "#{l}.#{@localization_key.localization_key}"
      end
      respond_to :js
    end

  end
end
