# frozen_string_literal: true

module Lit
  class CloudTranslationsController < ::Lit::ApplicationController
    def show
      @target_localization = Localization.find(params[:localization_id])
      @localization_key = @target_localization.localization_key
      @localization = @localization_key.localizations.joins(:locale)
                                       .find_by!(lit_locales: { locale: params[:from] })
      opts =
        {
          text: @localization.value,
          from: params[:from],
          to: @target_localization.locale.locale
        }.compact
      @translated_text = Lit::CloudTranslation.translate(opts)
    end
  end
end
