require_dependency "lit/api/v1/base_controller"

module Lit
  class Api::V1::LocalizationKeysController < Api::V1::BaseController
    def index
      @localization_keys = LocalizationKey
      if params[:after].present?
        @localization_keys = @localization_keys.after(DateTime.parse(params[:after])).to_a
      else
        @localization_keys = @localization_keys.all
      end
      render :json=>@localization_keys.as_json(:root=>false, :only=>[:id, :localization_key])
    end
  end
end

