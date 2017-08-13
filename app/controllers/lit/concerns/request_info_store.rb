module Lit
  module Concerns
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
end
