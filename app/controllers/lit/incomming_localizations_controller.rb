require_dependency 'lit/application_controller'

module Lit
  class IncommingLocalizationsController < ApplicationController
    before_action :find_source_and_incomming_localizations
    before_action :find_icomming_localization, only: %i[accept destroy]

    def index; end

    def accept
      @incomming_localization.accept
      respond_to do |format|
        format.html { finish_request }
        format.js
      end
    end

    def accept_all
      ActiveRecord::Base.transaction do
        @incomming_localizations.each(&:accept)
      end
      finish_request
    end

    def reject_all
      @incomming_localizations.destroy_all
      finish_request
    end

    def destroy
      @incomming_localization.destroy
      respond_to do |format|
        format.html { redirect_to source_incomming_localizations_path(@source) }
        format.js
      end
    end

    private

    def find_icomming_localization
      @incomming_localization = @source.incomming_localizations
                                       .find(params[:id].to_i)
    end

    def find_source_and_incomming_localizations
      @source = Source.find(params[:source_id].to_i)
      @incomming_localizations = @source.incomming_localizations
    end

    def finish_request
      redirect_to_back_or_default(
        fallback_location: source_incomming_localizations_path(@source)
      )
    end
  end
end
