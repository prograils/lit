require 'net/http'
module Lit
  class Source < ActiveRecord::Base
    LOCALES_PATH = "/api/v1/locales.json"
    LOCALIZATION_KEYS_PATH = "/api/v1/localization_keys.json"
    LOCALIZATIONS_PATH = "/api/v1/localizations.json"
    LAST_CHANGE_PATH = "/api/v1/last_change.json"

    ## ASSOCIATIONS
    has_many :incomming_localizations

    ## VALIDATIONS
    validates :api_key, :identifier, :url,
              :presence=>true
    validates :url,
              :format=>{:with=>/\Ahttps?:\/\/.*\/.*[^\/]\Z/i}

    unless defined?(::ActionController::StrongParameters)
      attr_accessible :api_key, :identifier, :url
    end

    ## BEFORE & AFTER
    before_create :set_last_updated_at_upon_creation
    after_validation :check_if_url_is_valid


    def get_last_change
      result = get_from_remote(LAST_CHANGE_PATH)
      result["last_change"] unless result.nil?
    end

    def synchronize
      after = self.last_updated_at.nil? ? nil : self.last_updated_at.to_s(:db)
      result = get_from_remote(LOCALIZATIONS_PATH, {:after=>after})
      unless result.nil?
        if result.is_a?(Array)
          result.each do |r|
            il = IncommingLocalization.new
            if ::Rails::VERSION::MAJOR < 4
              il = IncommingLocalization.where(:incomming_id=>r["id"]).first_or_initialize
            else
              il = IncommingLocalization.find_or_initialize_by(:incomming_id=>r["id"])
            end
            il.source = self
            il.locale_str = r["locale_str"]
            il.locale = Locale.where(:locale=>il.locale_str).first
            il.localization_key_str = r["localization_key_str"]
            il.localization_key = LocalizationKey.where(:localization_key=>il.localization_key_str).first
            unless il.is_duplicate?(r['value'])
              il.save!
              IncommingLocalization.where(:id=>il.id).
                update_all ['translated_value=?', r["value"]]
            end
          end
          last_change = get_last_change
          last_change = DateTime.parse(last_change) unless last_change.nil?
          touch_last_updated_at(last_change)
          save
        end
      end
    end

    def touch_last_updated_at!
      touch_last_updated_at
      save
    end

    private
      def touch_last_updated_at(time=nil)
        self.last_updated_at = time || Time.now
      end

      def check_if_url_is_valid
        if self.errors.empty? && (self.new_record? || self.url_changed?)
            self.errors.add(:url, "is not accessible") if get_last_change.nil?
        end
      end

      def get_from_remote(path, query_values={})
        result = nil
        begin
          uri = URI(self.url+path)
          query_values.each do |k,v|
            params = URI.decode_www_form(uri.query || "") << [k, v]
            uri.query = URI.encode_www_form(params)
          end
          req = Net::HTTP::Get.new(uri.request_uri)
          req.add_field("Authorization", %(Token token="#{self.api_key}"))
          res = Net::HTTP.new(uri.host, uri.port).start do |http|
            http.request(req)
          end
          if res.is_a?(Net::HTTPSuccess)
            result = JSON.parse(res.body)
          end
        rescue
        end
        result
      end

      def set_last_updated_at_upon_creation
        if self.last_updated_at.blank?
          touch_last_updated_at if Lit.set_last_updated_at_upon_creation
        end
      end
  end
end
