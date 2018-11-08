require 'net/http'
module Lit
  class Source < ActiveRecord::Base
    LOCALES_PATH = '/api/v1/locales.json'.freeze
    LOCALIZATION_KEYS_PATH = '/api/v1/localization_keys.json'.freeze
    LOCALIZATIONS_PATH = '/api/v1/localizations.json'.freeze
    LAST_CHANGE_PATH = '/api/v1/last_change.json'.freeze

    ## ASSOCIATIONS
    has_many :incomming_localizations

    ## VALIDATIONS
    validates :api_key, :identifier, :url,
              presence: true
    validates :url,
              format: { with: %r{\Ahttps?://.*/.*[^/]\Z}i }

    ## ACCESSORS
    unless defined?(::ActionController::StrongParameters)
      attr_accessible :api_key, :identifier, :url
    end

    ## BEFORE & AFTER
    before_create :set_last_updated_at_upon_creation
    after_validation :check_if_url_is_valid

    def last_change
      result = RemoteInteractorService.new(self).send_request(LAST_CHANGE_PATH)
      result['last_change'] unless result.nil?
    end

    def touch_last_updated_at!
      assign_last_updated_at
      save
    end

    def assign_last_updated_at(time = nil)
      self.last_updated_at = time || Time.now
    end

    private

    def check_if_url_is_valid
      return if errors.present? || !(new_record? || url_changed?) ||
                last_change.present?
      errors.add :url, 'is not accessible'
    end

    def set_last_updated_at_upon_creation
      return if last_updated_at.blank? && !Lit.set_last_updated_at_upon_creation
      assign_last_updated_at
    end
  end
end
