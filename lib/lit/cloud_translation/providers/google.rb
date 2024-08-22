# frozen_string_literal: true

require_relative "base"
begin
  require "google/cloud/translate"
rescue LoadError
  raise StandardError,
    'You need to add "gem \'google-cloud-translate\'" to your Gemfile to support Google Cloud Translation'
end

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
  #   # Instead of providing the keyfile, credentials can be given using
  #   # GOOGLE_TRANSLATE_API_<element> environment variables, where e.g.
  #   # the GOOGLE_TRANSLATE_API_PROJECT_ID variable corresponds to the
  #   # `project_id` element of your credentials. Typically, only the following
  #   # variables are mandatory:
  #   # * GOOGLE_TRANSLATE_API_PROJECT_ID
  #   # * GOOGLE_TRANSLATE_API_PRIVATE_KEY_ID
  #   # * GOOGLE_TRANSLATE_API_PRIVATE_KEY (be sure that it contains correct line breaks)
  #   # * GOOGLE_TRANSLATE_API_CLIENT_EMAIL
  #   # * GOOGLE_TRANSLATE_API_CLIENT_ID
  #   #
  #   # Alternatively, the contents of that file can be given as a Ruby hash
  #   # and passed like the following (be careful to use secrets or something
  #   # that prevents exposing private credentials):
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
    def translate(text:, to:, from: nil, **)
      result = client.translate(sanitize_text(text), from:, to:, **)
      unsanitize_text(
        case result
        when translation_class then result.text
        when Array then result.map(&:text)
        end
      )
    rescue Signet::AuthorizationError => e
      error_description =
        "Google credentials error: " + # rubocop:disable Style/RescueModifier
        JSON.parse(e.response.body)["error_description"] rescue "Unknown error"
      raise ::Lit::CloudTranslation::TranslationError, error_description,
        cause: e
    rescue ::Google::Cloud::Error => e
      raise ::Lit::CloudTranslation::TranslationError, e.message, cause: e
    end

    private

    def client
      @client ||= begin
        args = {
          project_id: config.keyfile_hash["project_id"], credentials: config.keyfile_hash,
          version: :v2
        }
        ::Google::Cloud::Translate.new(**args)
      end
    end

    def translation_class
      ::Google::Cloud::Translate::V2::Translation
    end

    def default_config
      if ENV["GOOGLE_TRANSLATE_API_KEYFILE"].blank?
        env_keys = ENV.keys.grep(/\AGOOGLE_TRANSLATE_API_/)
        keyfile_keys = env_keys.map(&:downcase).map { |k| k.gsub("google_translate_api_", "") }
        keyfile_key_to_env_key_mapping = keyfile_keys.zip(env_keys).to_h
        return {
          keyfile_hash: keyfile_key_to_env_key_mapping.transform_values do |env_key|
            ENV[env_key]
          end
        }
      end
      {keyfile_hash: JSON.parse(File.read(ENV["GOOGLE_TRANSLATE_API_KEYFILE"]))}
    rescue JSON::ParserError
      raise
    rescue Errno::ENOENT
      {keyfile_hash: nil}
    end

    def require_config!
      return if config.keyfile_hash.present?

      raise "GOOGLE_TRANSLATE_API_KEYFILE env or `config.keyfile_hash` not given"
    end

    def sanitize_text(text_or_array)
      case text_or_array
      when String
        text_or_array.gsub(/%{(.+?)}/, '<code>__LIT__\1__LIT__</code>').gsub("\r\n", "<code>0</code>")
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
        text_or_array.gsub(%r{<code>0</code>}, "\r\n").gsub(%r{<code>__LIT__(.+?)__LIT__</code>}, '%{\1}')
      when Array
        text_or_array.map { |s| unsanitize_text(s) }
      else
        raise TypeError
      end
    end
  end
end
