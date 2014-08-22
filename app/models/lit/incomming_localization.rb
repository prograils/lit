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
      translated_value
    end

    def full_key
      [locale_str, localization_key_str].join('.')
    end

    def accept
      if localization.present?
        localization.translated_value = translated_value
        localization.is_changed = true
        localization.save
      else
        unless locale.present?
          self.locale = Lit::Locale.where(locale: locale_str).first_or_create
        end
        unless localization_key.present?
          self.localization_key = Lit::LocalizationKey.
                where(localization_key: localization_key_str).
                first_or_create
        end
        unless localization.present?
          self.localization = Lit::Localization.
                where(localization_key_id: self.localization_key.id).
                where(locale_id: self.locale.id).
                first_or_initialize
          localization.translated_value = translated_value
          localization.is_changed = true
          localization.save!
        end
      end
      Lit.init.cache.update_cache localization.full_key, localization.get_value
      destroy
    end

    def is_duplicate?(val)
      set_localization_id unless localization.present?
      if localization
        translated_value = localization.
                read_attribute_before_type_cast('translated_value')
        if localization.is_changed? && !translated_value.nil?
          translated_value == val
        else
          localization.read_attribute_before_type_cast('default_value') == val
        end
      else
        false
      end
    end

    private

    def set_localization_id
      if locale.present? && localization_key.present?
        self.localization = localization_key.localizations.where(locale_id: locale_id).first
      end
    end
  end
end
