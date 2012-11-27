module Lit
  class ApplicationController < ActionController::Base
    before_filter :authenticate

    private
      def authenticate
        if Lit.authentication_function
          send(Lit.authentication_function)
        end
      end
  end
end
