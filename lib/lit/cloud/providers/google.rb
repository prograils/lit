# frozen_string_literal: true

require_relative 'base'
require 'google/cloud/translate'

module Lit::Cloud::Providers
  # Google Cloud Translation API provider for Lit translation suggestions.
  #
  # Configuration:
  #
  #   require 'lit/cloud/providers/google'
  #
  #   Lit::Cloud.provider = Lit::Cloud::Providers::Google
  #
  #   # Service account configuration can be given via a file pointed to by
  #   # ENV['GOOGLE_TRANSLATE_API_KEYFILE'] (see here:
  #   # https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
  #   #
  #   # Alternatively, the contents of that file can be given as a Ruby hash
  #   # and passed like the following:
  #
  #   Lit::Cloud.configure do |config|
  #     config.keyfile_hash = {
  #       'type' => 'service_account',
  #       'project_id' => 'foo',
  #       'private_key_id' => 'keyid',
  #       ... # see link above for reference
  #     }
  #   end
  class Google < Base
    def translate(text:, from: nil, to:, opts: {})
      @client ||=
        ::Google::Cloud::Translate.new(project_id: config.keyfile_hash['project_id'],
                                       credentials: config.keyfile_hash)
      result = @client.translate(text, from: from, to: to, **opts)
      case result
      when ::Google::Cloud::Translate::Translation then result.text
      when Array then result.map(&:text)
      end
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
  end
end
