# frozen_string_literal: true

module Lit::Cloud::Providers
  class Base
    attr_reader :config

    def initialize(config)
      default_config.each do |key, value|
        config[key] ||= value
      end
      @config = config
    end

    def translate(text:, from:, to:, opts: {}) # rubocop:disable Lint/UnusedMethodArgument, Metrics/LineLength
      raise NotImplementedError
    end

    private

    def default_config
      {}
    end

    private_class_method :new

    class TranslationError < StandardError; end

    class << self
      def translate(*args)
        instance.translate(*args)
      end

      private

      def instance
        @instance ||= new(config)
      end

      def configure
        yield config
      end

      def config
        @config ||= OpenStruct.new
      end
    end
  end
end
