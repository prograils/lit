require 'net/http'
module Lit
  class Source < ActiveRecord::Base
    LOCALES_PATH = "/api/v1/locales.json"
    LOCALIZATION_KEYS_PATH = "/api/v1/localization_keys.json"
    LOCALIZATIONS_PATH = "/api/v1/localizations.json"
    LAST_CHANGE_PATH = "/api/v1/last_change.json"
    ## VALIDATIONS
    validates :api_key, :identifier, :url,
              :presence=>true
    validates :url,
              :format=>{:with=>/\Ahttps?:\/\/.*\/.*[^\/]\Z/i}

    unless defined?(::ActionController::StrongParameters)
      attr_accessible :api_key, :identifier, :url
    end

    ## BEFORE & AFTER
    after_validation :check_if_url_is_valid


    private
      def check_if_url_is_valid
        if self.errors.empty? && (self.new_record? || self.url_changed?)
          begin
            uri = URI(self.url+LAST_CHANGE_PATH)
            req = Net::HTTP::Get.new(uri.path)
            req.add_field("Authorization", %(Token token="#{self.api_key}"))
            res = Net::HTTP.new(uri.host, uri.port).start do |http|
              http.request(req)
            end
            self.errors.add(:url, "is not accessible") unless res.is_a?(Net::HTTPSuccess)
          rescue
            self.errors.add(:url, "is not accessible")
          end
        end
      end
  end
end
