module Lit
  class Railtie < ::Rails::Railtie
    initializer :lit_middleware do |app|
      app.config.middleware.insert_after ActionDispatch::RequestId, Lit::Middleware

      ActiveSupport::Reloader.to_complete do
        Thread.current[:localization_cache_valid] = false
      end
    end
  end
end
