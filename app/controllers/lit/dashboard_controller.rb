require_dependency 'lit/application_controller'

module Lit
  class DashboardController < ::Lit::ApplicationController
    def index
      @locales = Lit::Locale.ordered.visible
    end

    def clear_usage_data
      Lit::LocalizationKey.where.not(used_last_at: nil).update_all(usage_count: 0, used_last_at: nil)
      redirect_to root_path
    end
  end
end
