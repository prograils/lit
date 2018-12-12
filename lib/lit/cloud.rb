# frozen_string_literal: true

module Lit
  module Cloud
    module_function def provider=(provider)
      @provider = provider.tap(&:require_config!)
    end

    module_function def provider
      @provider
    end

    module_function def translate(*args)
      provider.translate(*args)
    end
  end
end
