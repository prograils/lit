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

      opts.merge!(ignore_tags: "i18n", tag_handling: :xml)

      res = ::DeepL.translate(convert_ignore_tags(text), to_deepl_source_locale(from), to_deepl_target_locale(to), opts)
      revert_ignore_tags(res.text) if res.is_a?(DeepL::Resources::Text)
    end

    private

    def convert_ignore_tags(text)
      text.gsub(/%{(\w+)}/) { "<i18n>#{Regexp.last_match[1]}</i18n>" }
    end

    def revert_ignore_tags(text)
      text.gsub(/<i18n>(\w+)<\/i18n>/) { "%{#{Regexp.last_match[1]}}" }
    end

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
