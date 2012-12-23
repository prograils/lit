require 'bootstrap-sass'
module Lit
  class Engine < ::Rails::Engine
    isolate_namespace Lit

    initializer "lit.assets.precompile" do |app|
      app.config.assets.precompile = %w(application.css application.js)
    end
  end
end
