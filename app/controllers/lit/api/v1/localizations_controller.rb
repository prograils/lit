module Lit
  class Api::V1::LocalizationsController < Api::V1::BaseController
    def index
      @localizations = Localization
      if params[:after].present?
        @localizations = @localizations.after(DateTime.parse(params[:after])).to_a
      else
        @localizations = @localizations.all
      end
    end

    def last_change
      @localization = Localization.order('updated_at DESC').first
    end
  end
end
