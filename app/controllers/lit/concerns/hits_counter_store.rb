# frozen_string_literal: true

require 'lit/hits_counter_batch'

module Lit
  module Concerns
    module HitsCounterStore
      extend ::ActiveSupport::Concern
      included do
        before_action :init_hits_counter
        after_action :flush_hits_counter
      end

      private

      def init_hits_counter
        Thread.current[:lit_hits_counter_batch] = Lit::HitsCounterBatch.new
      end

      def flush_hits_counter
        Thread.current[:lit_hits_counter_batch].flush
        Thread.current[:lit_hits_counter_batch] = nil
      end
    end
  end
end
