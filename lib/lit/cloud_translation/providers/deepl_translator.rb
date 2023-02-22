# frozen_string_literal: true

require_relative 'base'
require 'deepl'

module Lit::CloudTranslation::Providers
  # DeepL Translate API provider for Lit translation suggestions.
  #
  # Configuration:
  #
  #   require 'lit/cloud_translation/providers/deepl_translator'
  #
  #   Lit::CloudTranslation.provider = Lit::CloudTranslation::Providers::DeeplTranslator
  #
  #   Lit::CloudTranslation.configure do |config|
  #     config.api_key = 'the_api_key'
  #   end
  class DeeplTranslator < Base
    def translate(text:, from: nil, to:, **opts)
      configure_api_key

      res = ::DeepL.translate(text, to_deepl_source_locale(from), to_deepl_target_locale(to), opts)
      if res.is_a?(DeepL::Resources::Text)
        res.text
      else
        res.map(&:text)
      end
    end

    private

    # Convert 'es-ES' to 'ES', en-us to EN
    def to_deepl_source_locale(locale)
      locale.to_s.split('-', 2).first.upcase
    end

    # Convert 'es-ES' to 'ES' but warn about locales requiring a specific variant
    def to_deepl_target_locale(locale)
      loc, sub = locale.to_s.split('-')
      loc.upcase
    end

    def configure_api_key
      base_config = config
      ::DeepL.configure do |config|
        config.auth_key = base_config.api_key
        config.host = 'https://api.deepl.com'
        config.version = 'v1'
      end
    end
  end
end
