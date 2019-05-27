require_dependency 'lit/application_controller'

module Lit
  class LocalesController < ApplicationController
    def index
      @locales = Locale.ordered

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @locales }
      end
    end

    def hide
      binding.pry
      @locale = Locale.find(params[:id])
      @locale.toggle :is_hidden
      @locale.save
      respond_to do |format|
        format.json { render json: { hidden: @locale.is_hidden? } }
      end
    end

    def destroy
      @locale = Locale.find(params[:id])
      @locale.destroy

      respond_to do |format|
        format.html { redirect_to locales_url }
        format.json { head :no_content }
      end
    end
  end
end
