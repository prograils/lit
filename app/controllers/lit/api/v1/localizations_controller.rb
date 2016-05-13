module Lit
  class Api::V1::LocalizationsController < Api::V1::BaseController
    def index
      @localizations = Localization
      if params[:after].present?
        @localizations = @localizations.after(DateTime.parse(params[:after])).to_a
      else
        @localizations = @localizations.all
      end
      render json: @localizations.as_json(root: false, only: [:id, :localization_key_id, :locale_id], methods: [:value, :localization_key_str, :locale_str])
    end

    def last_change
      @localization = Localization.where('modified_at IS NOT NULL')
                                  .order('modified_at DESC').first
      if @localization.present?
        render json: @localization.as_json(root: false, only: [], methods: [:last_change])
      else
        render json: { last_change: nil }
      end
    end
  end
end
