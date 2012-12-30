require "lit/engine"
require 'lit/loader'

module Lit
  mattr_accessor :authentication_function
  mattr_accessor :key_value_engine
  class << self
    attr_accessor :loader
  end
  def self.init
    if self.loader.nil?
      self.loader ||= Loader.new
      #if loading all translations on start, migrations have to be performed
      #already, fails on first deploy
      #self.loader.cache.load_all_translations
    end
    self.loader
  end

  def self.get_key_value_engine
    case Lit.key_value_engine
        when 'redis'
          require 'lit/adapters/redis_storage'
          return RedisStorage.new
        else
          require 'lit/adapters/hash_storage'
          return HashStorage.new
    end
  end
end

if defined? Rails
  require 'lit/rails'
end
