module Lit
  module Concerns
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
end
