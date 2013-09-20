module Lit
  class ApplicationController < ActionController::Base
    before_filter :authenticate
    before_filter :stop_hits_counter
    after_filter :restore_hits_counter

    private
      def authenticate
        if Lit.authentication_function.present?
          send(Lit.authentication_function)
        end
      end

      def stop_hits_counter
        Lit.init.cache.stop_hits_counter
      end

      def restore_hits_counter
        Lit.init.cache.restore_hits_counter
      end
  end
end
