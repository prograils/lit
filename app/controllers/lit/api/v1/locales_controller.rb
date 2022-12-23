require_dependency 'lit/api/v1/base_lit_controller'

module Lit
  module Api
    module V1
      class LocalesController < Api::V1::BaseLitController
        def index
          @locales = Locale.all
          render json: @locales.as_json(root: false, only: %i[id locale])
        end
      end
    end
  end
end
