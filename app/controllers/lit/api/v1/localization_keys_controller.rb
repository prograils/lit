require_dependency 'lit/api/v1/base_lit_controller'

module Lit
  class Api::V1::LocalizationKeysController < Api::V1::BaseLitController
    def index
      @localization_keys = fetch_localization_keys
      render json: @localization_keys.as_json(
        root: false, only: %i[id localization_key is_deleted]
      )
    end

    private

    def fetch_localization_keys
      if params[:after].present?
        after_date = Time.parse(params[:after])
        LocalizationKey.after(after_date).to_a
      else
        LocalizationKey.all
      end
    end
  end
end
