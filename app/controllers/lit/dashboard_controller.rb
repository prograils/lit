require_dependency "lit/application_controller"

module Lit
  class DashboardController < ::Lit::ApplicationController
    def index
      @locales = Lit::Locale.ordered.visible
    end
  end
end
