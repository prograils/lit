require "lit/engine"
require "lit/loader"
require "lit/adapters"

module Lit
  mattr_accessor :authentication_function
  mattr_accessor :authentication_verification
  mattr_accessor :key_value_engine
  mattr_accessor :redis_url
  mattr_accessor :storage_options
  mattr_accessor :store_humanized_key
  mattr_accessor :store_humanized_key_ignored_keys
  mattr_accessor :humanize_key_ignored
  mattr_accessor :ignored_keys
  mattr_accessor :ignore_yaml_on_startup
  mattr_accessor :api_enabled
  mattr_accessor :api_key
  mattr_accessor :all_translations_are_html_safe
  mattr_accessor :set_last_updated_at_upon_creation
  mattr_accessor :store_request_info
  mattr_accessor :store_request_keys
  mattr_accessor :hits_counter_enabled

  class << self
    attr_accessor :loader
  end

  def self.init
    @@table_exists ||= check_if_table_exists
    if loader.nil? && @@table_exists
      self.loader ||= Loader.new
      Lit.store_humanized_key = false if Lit.store_humanized_key.nil?
      Lit.store_humanized_key_ignored_keys = [] if Lit.store_humanized_key_ignored_keys.nil?
      Lit.humanize_key_ignored = %w[i18n date datetime number time support]
      Lit.humanize_key_ignored |= Lit.store_humanized_key_ignored_keys
      Lit.humanize_key_ignored = Regexp.new("(#{Lit.humanize_key_ignored.join("|")}).*")
      Lit.ignore_yaml_on_startup = true if Lit.ignore_yaml_on_startup.nil?

      Lit.ignored_keys = Lit.ignored_keys.split(",").map(&:strip) if Lit.ignored_keys.is_a?(String)
      Lit.ignored_keys = [] unless Lit.ignored_keys.is_a?(Array)
      Lit.ignored_keys = Lit.ignored_keys.map(&:freeze).freeze

      Lit.hits_counter_enabled = false if Lit.hits_counter_enabled.nil?
      Lit.store_request_info = false if Lit.store_request_info.nil?
      Lit.store_request_keys = false if Lit.store_request_keys.nil?

      # if loading all translations on start, migrations have to be already
      # performed, fails on first deploy
      # self.loader.cache.load_all_translations
      Lit.storage_options ||= {}
    end
    self.loader
  end

  def self.check_if_table_exists
    Lit::Locale.table_exists?
  rescue ActiveRecord::ActiveRecordError => e
    log_txt =
      "An #{e.class} error has been raised during Lit initialization. " \
        "Lit assumes that database tables do not exist.\n\n" \
        "Error: #{e.message}\n\n" \
        "Backtrace:\n" \
        "#{e.backtrace.join("\n")}"
    Logger.new(STDOUT).error(log_txt) if ::Rails.env.test? # ensure this is logged to stdout in test
    ::Rails.logger.error(log_txt)
    false
  end

  def self.get_key_value_engine
    case Lit.key_value_engine
    when "redis"
      require "lit/adapters/redis_storage"
      ::Lit::Adapters::RedisStorage.new
    else
      require "lit/adapters/hash_storage"
      ::Lit::Adapters::HashStorage.new
    end
  end

  def self.fallback=(_value)
    ::Rails.logger.error "[DEPRECATION] Lit.fallback= has been deprecated, please use `config.i18n.fallbacks` instead"
  end

  def self.humanize_key=(value)
    ::Rails.logger.error "[DEPRECATION] Lit.humanize_key= has been deprecated, please use `Lit.store_humanized_key` instead"
    Lit.store_humanized_key = value
  end
end

require "lit/rails" if defined?(Rails)
