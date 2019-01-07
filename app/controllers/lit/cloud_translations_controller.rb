# frozen_string_literal: true

module Lit
  class CloudTranslationsController < ::Lit::ApplicationController
    def show
      params.delete(:from) if params[:from] == 'auto'
      @target_localization = Localization.find(params[:localization_id])
      @localization_key = @target_localization.localization_key
      if params[:from]
        @localization = @localization_key.localizations.joins(:locale)
                                         .find_by!(lit_locales: { locale: params[:from] })
      end
      opts =
        {
          # if :from was auto, translate from the target localization's
          # current text itself
          text: (@localization || @target_localization).value,
          from: params[:from],
          to: @target_localization.locale.locale
        }.compact
      @translated_text = Lit::CloudTranslation.translate(opts)
    rescue Lit::CloudTranslation::TranslationError => e
      @error_message = "Translation failed. #{e.message}"
    end
  end
end
