require_dependency 'lit/application_controller'

module Lit
  class SourcesController < ApplicationController
    before_action :find_source, except: %i[index new create]
    def index
      @sources = Source.all
    end

    def show; end

    def new
      @source = Source.new
    end

    def edit; end

    def synchronize
      @source.update_column(:sync_complete, false)
      if defined?(ActiveJob)
        SynchronizeSourceJob.perform_later(@source)
      else
        SynchronizeSourceService.new(@source).execute
      end
      redirect_to lit.source_incomming_localizations_path(@source)
    end

    def touch
      @source.touch_last_updated_at!
      redirect_to_back_or_default fallback_location: source_path(@source)
    end

    def create
      @source = Source.new(clear_params)
      if @source.save
        redirect_to @source, notice: 'Source was successfully created.'
      else
        render action: 'new'
      end
    end

    def update
      if @source.update_attributes(clear_params)
        redirect_to @source, notice: 'Source was successfully updated.'
      else
        render action: 'edit'
      end
    end

    def destroy
      @source.destroy
      redirect_to sources_url
    end

    def sync_complete
      render json: { sync_complete: @source.sync_complete }
    end

    private

    def find_source
      @source = Source.find(params[:id])
    end

    def clear_params
      if defined?(::ActionController::StrongParameters)
        params.require(:source).permit(:identifier, :url, :api_key)
      else
        params[:source]
      end
    end
  end
end
