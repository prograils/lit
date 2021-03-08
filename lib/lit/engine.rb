module Lit
  class Engine < ::Rails::Engine
    require 'jquery-rails'

    config.autoload_paths += %W[#{Lit::Engine.root}/app/controllers/lit/concerns]
    paths.add 'lib', eager_load: true # Zeitwerk compatibility

    isolate_namespace Lit

    initializer 'lit.assets.precompile' do |app|
      app.config.assets.precompile += %w[lit/application.css lit/application.js]
      app.config.assets.precompile += %w[lit/lit_frontend.css lit/lit_frontend.js]
    end

    initializer 'lit.reloader' do |app|
      config.to_prepare do
        Lit.loader.cache.reset_local_cache if Lit.loader
      end
    end

    initializer 'lit.migrations.append' do |app|
      unless app.root.to_s.include?(root.to_s)
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer :append_before_action do
      ActionController::Base.send :before_action do
        Thread.current[:lit_thread_cache] = {}
      end
    end
  end
end
