# frozen_string_literal: true

module Lit
  module_function

  def version
    Gem::Version.new Version::STRING
  end

  module Version
    MAJOR = 2
    MINOR = 0
    TINY = 0

    STRING = [MAJOR, MINOR, TINY].compact.join(".")
  end
end
