require_dependency 'lit/application_controller'

module Lit
  class IncommingLocalizationsController < ApplicationController
    before_action :find_source

    def index
      @incomming_localizations = @source.incomming_localizations
    end

    def accept
      @incomming_localization = @source.incomming_localizations.find(params[:id].to_i)
      @incomming_localization.accept
      Lit.init.cache.refresh_key @incomming_localization.full_key
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end

    def accept_all
      @source.incomming_localizations.each do |li|
        li.accept
        Lit.init.cache.refresh_key li.full_key
      end
      redirect_to :back
    end

    def reject_all
      @source.incomming_localizations.destroy_all
      redirect_to :back
    end

    def destroy
      @incomming_localization = @source.incomming_localizations.find(params[:id].to_i)
      @incomming_localization.destroy
      respond_to do |format|
        format.html { redirect_to source_incomming_localizations_path(@source) }
        format.js
      end
    end

    private

    def find_source
      @source = Source.find(params[:source_id].to_i)
    end
  end
end
