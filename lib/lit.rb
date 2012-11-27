require "lit/engine"
require 'lit/loader'

module Lit
  mattr_accessor :authentication_function
  class << self
    attr_accessor :loader
  end
  def self.init
    self.loader ||= Loader.new
    self.loader
  end
end

if defined? Rails
  require 'lit/rails'
end
