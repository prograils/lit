require_dependency "lit/application_controller"

module Lit
  class LocalesController < ApplicationController
    def index
      @locales = Locale.ordered.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @locales }
      end
    end
    
    def hide
      @locale = Locale.find(params[:id])
      @locale.is_hidden = !@locale.is_hidden?
      @locale.save
      respond_to :js
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
