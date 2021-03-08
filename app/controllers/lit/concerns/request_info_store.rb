module Lit
  module RequestInfoStore
    extend ::ActiveSupport::Concern
    included do
      before_action :store_request_path
    end

    private

    def store_request_path
      Thread.current[:lit_current_request_path] = request&.path
    end
  end
end

module Lit::Concerns::RequestInfoStore
  extend ActiveSupport::Concern

  included do
    Rails.logger.info 'DEPRECATED: Use include Lit::RequestInfoStore'
    include Lit::RequestInfoStore
  end
end
