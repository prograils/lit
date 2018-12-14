# frozen_string_literal: true

require_relative 'base'
require 'google/cloud/translate'

module Lit::Cloud::Providers
  class Google < Base
    class << self
      def require_config!
        return if ENV['GOOGLE_TRANSLATE_API_KEYFILE'].present?
        raise 'GOOGLE_TRANSLATE_API_KEYFILE env not given'
      end
    end

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
      unless File.exist?(ENV['GOOGLE_TRANSLATE_API_KEYFILE'])
        raise "File does not exist: #{ENV['GOOGLE_TRANSLATE_API_KEYFILE']}"
      end
      { keyfile_hash: JSON.parse(File.read(ENV['GOOGLE_TRANSLATE_API_KEYFILE'])) }
    end
  end
end
