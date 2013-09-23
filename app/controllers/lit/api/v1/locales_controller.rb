require_dependency "lit/api/v1/base_controller"

module Lit
  module Api
    module V1
      class LocalesController < Api::V1::BaseController
        def index
          @locales = Locale.all
        end
      end
    end
  end
end
