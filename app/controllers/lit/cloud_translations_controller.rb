# frozen_string_literal: true

module Lit
  class CloudTranslationsController < ::Lit::ApplicationController
    def show
      @localization = Localization.find(params[:localization_id])
      opts =
        {
          text: @localization.default_value,
          from: params[:from],
          to: @localization.locale.locale
        }.compact
      opts.delete(:from) if opts[:from] == 'auto'
      @translated_text = Lit::Cloud.translate(opts)
    end
  end
end
