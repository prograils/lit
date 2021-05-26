module Lit::RequestKeysStore
  extend ::ActiveSupport::Concern
  included { before_action :init_request_keys }

  private

  def init_request_keys
    Thread.current[:lit_request_keys] = {}
  end
end
