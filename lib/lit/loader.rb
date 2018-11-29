require 'logger'
require 'lit/i18n_backend'
require 'lit/cache'
require 'lit/export'
require 'lit/import'

module Lit
  class Loader
    attr_accessor :cache
    attr_accessor :logger
    def initialize
      self.logger ||= Logger.new($stdout)
      self.cache ||= Cache.new
      I18n.backend = I18nBackend.new(self.cache)
    end
  end
end
