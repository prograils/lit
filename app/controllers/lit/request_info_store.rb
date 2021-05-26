module Lit::RequestInfoStore
  extend ::ActiveSupport::Concern
  included { before_action :store_request_path }

  private

  def store_request_path
    Thread.current[:lit_current_request_path] = request&.path
  end
end
