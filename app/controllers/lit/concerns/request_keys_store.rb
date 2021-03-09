module Lit
  module RequestKeysStore
    extend ::ActiveSupport::Concern
    included do
      before_action :init_request_keys
    end

    private

    def init_request_keys
      Thread.current[:lit_request_keys] = {}
    end
  end
end

module Lit::Concerns::RequestKeysStore
  extend ActiveSupport::Concern

  included do
    Rails.logger.info 'DEPRECATED: Use include Lit::RequestKeysStore'
    include Lit::RequestKeysStore
  end
end
