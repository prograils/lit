require 'logger'
require 'lit/i18n_backend'
require 'lit/cache'
require 'lit/export'
require 'lit/import'
require 'lit/cloud_translation'
require 'emoji_flag'

module Lit
  class Loader
    attr_accessor :cache
    attr_accessor :logger
    def initialize
      self.logger ||= Logger.new($stdout)
      self.logger.info 'initializing Lit' unless ::Rails.env.test?
      self.cache ||= Cache.new
      I18n.backend = I18nBackend.new(self.cache)
    end
  end
end
