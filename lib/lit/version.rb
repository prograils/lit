# frozen_string_literal: true

module Lit
  module_function

  def version
    Gem::Version.new Version::STRING
  end

  module Version
    MAJOR = 1
    MINOR = 1
    TINY = 4

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
