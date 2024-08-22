# frozen_string_literal: true

require_relative "base"
require "net/http"

module Lit::CloudTranslation::Providers
  # Yandex Translate API provider for Lit translation suggestions.
  #
  # Configuration:
  #
  #   require 'lit/cloud_translation/providers/yandex'
  #
  #   Lit::CloudTranslation.provider = Lit::CloudTranslation::Providers::Yandeex
  #
  #   # API key can be given via ENV['YANDEX_TRANSLATE_API_KEY'].
  #   #
  #   # Alternatively, it can be set programmatically after setting provider:
  #
  #   Lit::CloudTranslation.configure do |config|
  #     config.api_key = 'the_api_key'
  #   end
  class Yandex < Base
    def translate(text:, to:, from: nil, **opts) # rubocop:disable Metrics/MethodLength, Metrics/LineLength
      # puts "api key is: #{config.api_key}"
      # puts "translating #{text} from #{from} to #{to}"
      uri = URI("https://translate.yandex.net/api/v1.5/tr.json/translate")
      params = {
        key: config.api_key,
        text: sanitize_text(text),
        lang: [from, to].compact.join("-"),
        format: opts[:format],
        options: opts[:options]
      }.compact
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      unsanitize_text(
        case res
        when Net::HTTPOK
          translations = JSON.parse(res.body)["text"]
          (translations.size == 1) ? translations.first : translations
        else
          raise ::Lit::CloudTranslation::TranslationError,
            (JSON.parse(res.body)["message"] rescue "Unknown error: #{res.body}") # rubocop:disable Style/RescueModifier, Metrics/LineLength
        end
      )
    end

    private

    def default_config
      {api_key: ENV["YANDEX_TRANSLATE_API_KEY"]}
    end

    def require_config!
      return if config.api_key.present?
      raise "YANDEX_TRANSLATE_API_KEY env or `config.api_key` not given"
    end

    def sanitize_text(text_or_array)
      case text_or_array
      when String
        text_or_array.gsub(/%{(.+?)}/, '%{_LIT_\1_LIT_}')
      when Array
        text_or_array.map { |s| sanitize_text(s) }
      when nil
        ""
      else
        raise TypeError
      end
    end

    def unsanitize_text(text_or_array)
      case text_or_array
      when String
        text_or_array.gsub(/%{_LIT_(.+?)_LIT_}/, '%{\1}')
      when Array
        text_or_array.map { |s| unsanitize_text(s) }
      else
        raise TypeError
      end
    end
  end
end
