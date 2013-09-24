module Lit
  class IncommingLocalization < ActiveRecord::Base
    serialize :translated_value

    ## ASSOCIATIONS
    belongs_to :locale
    belongs_to :localization_key
    belongs_to :localization
    belongs_to :source

    unless defined?(::ActionController::StrongParameters)
      attr_accessible
    end

    ## BEFORE & AFTER
    before_create :set_localization_id


    def get_value
      self.translated_value
    end

    def full_key
      [self.locale_str, self.localization_key_str].join('.')
    end

    def accept
      if self.localization.present?
        self.localization.translated_value = self.translated_value
        self.localization.save
      else
        unless self.locale.present?
          self.locale = Lit::Locale.new
          self.locale.locale = self.locale_str
          self.locale.save
        end
        unless self.localization_key.present?
          self.localization_key = Lit::LocalizationKey.new
          self.localization_key.localization_key = self.localization_key_str
          self.localization_key.save
        end
        unless self.localization.present?
          self.localization = Lit::Localization.new
          self.localization.locale = self.locale
          self.localization.localization_key = self.localization_key
          self.localization.default_value = self.translated_value
          self.localization.save
        end
      end
      self.destroy
    end

    private
      def set_localization_id
        if self.locale.present? and self.localization_key.present?
          self.localization = self.localization_key.localizations.where(:locale_id=>self.locale_id).first
        end
      end
  end
end
