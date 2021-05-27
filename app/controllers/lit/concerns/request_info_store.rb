module Lit::Concerns::RequestInfoStore
  extend ActiveSupport::Concern

  included do
    Rails.logger.info 'DEPRECATED: Use include Lit::RequestInfoStore'
    include Lit::RequestInfoStore
  end
end
