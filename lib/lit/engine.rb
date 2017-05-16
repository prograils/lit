module Lit
  class Engine < ::Rails::Engine
    isolate_namespace Lit

    initializer 'lit.assets.precompile' do |app|
      app.config.assets.precompile += %w(lit/application.css lit/application.js)
      app.config.assets.precompile += %w(lit/lit_frontend.css lit/lit_frontend.js)
    end
  end
end
