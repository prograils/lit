require_dependency 'lit/api/v1/base_controller'

module Lit
  class Api::V1::SourcesController < Api::V1::BaseController
    def sync_complete
      @source = Source.find(params[:id])
      render json: { sync_complete: @source.sync_complete }
    end
  end
end
