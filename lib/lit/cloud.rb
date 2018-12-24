# frozen_string_literal: true

module Lit
  module Cloud
    # Sets the provider for cloud translations.
    # @param [Class] provider Selected translation provider,
    #   descending from Lit::Cloud::Providers::Base
    module_function def provider=(provider)
      @provider = provider
    end

    # Returns the currently active cloud translation provider,
    # descending from Lit::Cloud::Providers::Base.
    module_function def provider
      @provider
    end

    # Uses the active translation provider to translate a text or array of
    # texts.
    # @param [String, Array] text The text (or array of texts) to translate
    # @param [Symbol, String] from The language to translate from. If not given,
    #   auto-detection will be attempted.
    # @param [Symbol, String] to The language to translate to.
    # @param [Hash] opts Additional, provider-specific optional parameters.
    module_function def translate(text:, from: nil, to:, **opts)
      provider.translate(text: text, from: from, to: to, **opts)
    end

    # Optional if provider-speciffic environment variables are set correctly.
    # Configures the cloud translation provider with specific settings,
    # overriding those from environment if needed.
    #
    # @example
    #   Lit::Cloud.configure do |config|
    #     # For Yandex, this overrides the YANDEX_TRANSLATE_API_KEY env
    #     config.api_key = 'my_awesome_api_key'
    #   end
    module_function def configure(&block)
      unless provider
        raise 'Translation provider not selected yet. Use `Lit::Cloud' \
              '.provider = PROVIDER_KLASS` before calling #configure.'
      end
      provider.tap do |p|
        p.configure(&block)
      end
    end
  end
end
