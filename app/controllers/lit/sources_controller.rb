require_dependency "lit/application_controller"

module Lit
  class SourcesController < ApplicationController
    def index
      @sources = Source.all
    end

    def show
      @source = Source.find(params[:id])
    end

    def new
      @source = Source.new
    end

    def edit
      @source = Source.find(params[:id])
    end

    def synchronize
      @source = Source.find(params[:id])
      @source.synchronize
      redirect_to lit.source_incomming_localizations_path(@source)
    end

    def touch
      @source = Source.find(params[:id])
      @source.touch_last_updated_at!
      redirect_to request.env["HTTP_REFERER"].present? ? :back : @source
    end

    def create
      @source = Source.new(clear_params)
      if @source.save
        redirect_to @source, :notice => 'Source was successfully created.'
      else
        render :action => "new"
      end
    end

    def update
      @source = Source.find(params[:id])
      if @source.update_attributes(clear_params)
        redirect_to @source, :notice => 'Source was successfully updated.'
      else
        render :action => "edit"
      end
    end

    def destroy
      @source = Source.find(params[:id])
      @source.destroy
      redirect_to sources_url
    end

    private
      def clear_params
        if defined?(::ActionController::StrongParameters)
          params.require(:source).permit(:identifier, :url, :api_key)
        else
          params[:source]
        end
      end
  end
end
