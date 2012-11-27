require 'logger'
require 'lit/i18n_backend'
require 'lit/cache'

module Lit
  module Rails
    def self.initialize
      Lit.init
    end
  end
end

if defined?(Rails::Railtie)
  require 'lit/railtie'
else
  Lit::Rails.initialize
end
