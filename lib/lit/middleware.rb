require 'rack/body_proxy'

# A middleware that ensures the lit thread value is cleared after
# the last part of the body is rendered. This is useful when
# using streaming.j
#
# Uses Rack::BodyProxy, adapted from Rack::Lock's usage of the
# same pattern.
#

module Lit
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Thread.current[:localization_cache_valid] = false
      response = @app.call(env)

      # for streaming support wrap request in Rack::BodyProxy
      response << Rack::BodyProxy.new(response.pop) do
        Thread.current[:localization_cache_valid] = false
      end
    ensure
      Thread.current[:localization_cache_valid] = false
    end
  end
end
