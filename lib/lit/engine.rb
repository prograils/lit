module Lit
  class Engine < ::Rails::Engine
    isolate_namespace Lit

    config.after_initialize do
      ActiveSupport.on_load :action_controller do
        puts 'loading Lit::FrontendHelper'.upcase
        #ActionController::Base.send(:helper, Lit::FrontendHelper)
      end
    end
    initializer 'lit.assets.precompile' do |app|
      app.config.assets.precompile += %w(lit/application.css lit/application.js)
      app.config.assets.precompile += %w(lit/lit_frontend.css lit/lit_frontend.js)
    end
  end
end
