module Lit
  class Engine < ::Rails::Engine
    isolate_namespace Lit


    initializer "lit.assets.precompile" do |app|
      app.config.assets.precompile += %w(lit/application.css lit/application.js)
    end
  end
end
