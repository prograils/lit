module Lit::Concerns::RequestKeysStore
  extend ActiveSupport::Concern

  included do
    Rails.logger.info 'DEPRECATED: Use include Lit::RequestKeysStore'
    include Lit::RequestKeysStore
  end
end
