# frozen_string_literal: true

module Lit
  module Concerns
    # Usage:
    #
    # class ApplicationController
    #   include Lit::Concerns::DeferCacheFetching
    # end
    module DeferCacheFetching
      extend ::ActiveSupport::Concern

      module PrependedMethods
        def render
          return super unless Lit.get_key_value_engine.respond_to?(:defer)

          Lit.get_key_value_engine.defer(
            original_content_proc: -> { super },
            replacement_proc: ->(replaced) { response.body = replaced }
          )
        end
      end

      included do
        prepend PrependedMethods
      end
    end
  end
end
