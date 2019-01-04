# frozen_string_literal: true

require_relative 'base'
require 'google/cloud/translate'

module Lit::CloudTranslation::Providers
  # Google Cloud Translation API provider for Lit translation suggestions.
  #
  # Configuration:
  #
  #   require 'lit/cloud_translation/providers/google'
  #
  #   Lit::CloudTranslation.provider = Lit::CloudTranslation::Providers::Google
  #
  #   # Service account configuration can be given via a file pointed to by
  #   # ENV['GOOGLE_TRANSLATE_API_KEYFILE'] (see here:
  #   # https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
  #   #
  #   # Alternatively, the contents of that file can be given as a Ruby hash
  #   # and passed like the following:
  #
  #   Lit::CloudTranslation.configure do |config|
  #     config.keyfile_hash = {
  #       'type' => 'service_account',
  #       'project_id' => 'foo',
  #       'private_key_id' => 'keyid',
  #       ... # see link above for reference
  #     }
  #   end
  class Google < Base
    def translate(text:, from: nil, to:, **opts)
      @client ||=
        ::Google::Cloud::Translate.new(project_id: config.keyfile_hash['project_id'],
                                       credentials: config.keyfile_hash)
      result = @client.translate(sanitize_text(text), from: from, to: to, **opts)
      unsanitize_text(
        case result
        when ::Google::Cloud::Translate::Translation then result.text
        when Array then result.map(&:text)
        end
      )
    end

    private

    def default_config
      return { keyfile_hash: nil } if ENV['GOOGLE_TRANSLATE_API_KEYFILE'].blank?
      { keyfile_hash: JSON.parse(File.read(ENV['GOOGLE_TRANSLATE_API_KEYFILE'])) }
    rescue JSON::ParserError
      raise
    rescue Errno::ENOENT
      { keyfile_hash: nil }
    end

    def require_config!
      return if config.keyfile_hash.present?
      raise 'GOOGLE_TRANSLATE_API_KEYFILE env or `config.keyfile_hash` not given'
    end

    def sanitize_text(text_or_array)
      case text_or_array
      when String
        text_or_array.gsub(/%{(.+?)}/, '<code>__LIT__\1__LIT__</code>')
      when Array
        text_or_array.map { |s| sanitize_text(s) }
      else
        raise TypeError
      end
    end

    def unsanitize_text(text_or_array)
      case text_or_array
      when String
        text_or_array.gsub(/<code>__LIT__(.+?)__LIT__<\/code>/, '%{\1}')
      when Array
        text_or_array.map { |s| unsanitize_text(s) }
      else
        raise TypeError
      end
    end
  end
end
