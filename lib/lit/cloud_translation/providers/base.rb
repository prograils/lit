# frozen_string_literal: true

module Lit::CloudTranslation::Providers
  # Abstract base class for cloud translation providers, providing a skeleton
  # for the provider's functionality (mainly the #translate method) as well as
  # a configuration management mechanism.
  class Base
    attr_reader :config

    def initialize(config)
      default_config.each do |key, value|
        config[key] ||= value
      end
      @config = config
    end

    # Translates a given text from a given language to a different one.
    # @param [String, Array] text The text (or array of texts) to translate
    # @param [Symbol, String] from The language to translate from. If not given,
    #   auto-detection will be attempted.
    # @param [Symbol, String] to The language to translate to.
    # @param [Hash] opts Additional, provider-specific optional parameters.
    def translate(text:, from: nil, to:, **opts) # rubocop:disable Lint/UnusedMethodArgument, Metrics/LineLength
      raise NotImplementedError
    end

    private

    # Loads specific information from environment variables or other sources
    # as the default configuartion for the translation provider.
    #
    # This can be overridden using `Lit::CloudTranslation.configure`.
    def default_config
      {}
    end

    private_class_method :new

    class << self
      # Using the provider object's singleton instance, translates a given text from
      # a given language to a different one.
      # @param [String, Array] text The text (or array of texts) to translate
      # @param [Symbol, String] from The language to translate from. If not given,
      #   auto-detection will be attempted.
      # @param [Symbol, String] to The language to translate to.
      # @param [Hash] opts Additional, provider-specific optional parameters.
      def translate(text:, from: nil, to:, **opts)
        instance.translate(text: text, from: from, to: to, **opts)
      end

      def configure
        yield config if block_given?
      end

      private

      def instance
        @instance ||= new(config)
      end

      def config
        @config ||= OpenStruct.new
      end
    end
  end
end
