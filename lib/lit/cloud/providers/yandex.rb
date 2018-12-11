# frozen_string_literal: true

require_relative 'base'
require 'net/http'

module Lit::Cloud::Providers
  class Yandex < Base
    def translate(text:, from: nil, to:, opts: {}) # rubocop:disable Metrics/MethodLength, Metrics/LineLength
      # puts "api key is: #{config.api_key}"
      # puts "translating #{text} from #{from} to #{to}"
      uri = URI('https://translate.yandex.net/api/v1.5/tr.json/translate')
      params = {
        key: config.api_key,
        text: text,
        lang: [from, to].compact.join('-'),
        format: opts[:format],
        options: opts[:options]
      }.compact
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      case res
      when Net::HTTPOK
        translations = JSON.parse(res.body)['text']
        translations.size == 1 ? translations.first : translations
      else
        raise TranslationError,
              (JSON.parse(res.body) rescue "Unknown error: #{res.body}") # rubocop:disable Style/RescueModifier, Metrics/LineLength
      end
    end

    private

    def default_config
      { api_key: ENV['YANDEX_TRANSLATE_API_KEY'] }
    end
  end
end
