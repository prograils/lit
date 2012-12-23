require_dependency "lit/application_controller"

module Lit
  class DashboardController < ApplicationController
    def index
      @locales = Lit::Locale.ordered
    end
  end
end
