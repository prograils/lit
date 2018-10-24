module Lit
  class IncommingLocalization < ActiveRecord::Base
    serialize :translated_value

    ## ASSOCIATIONS
    belongs_to :locale
    belongs_to :localization_key
    belongs_to :localization
    belongs_to :source

    ## ACCESSORS
    attr_accessible unless defined?(::ActionController::StrongParameters)

    ## BEFORE & AFTER
    before_validation :set_localization, on: :create

    def translation
      translated_value
    end

    def full_key
      [locale_str, localization_key_str].join('.')
    end

    def accept
      if localization.present?
        update_existing_localization_data
        update_existing_localization_key_data
      else
        assign_new_localization_data
      end
      update_cache
      destroy
    end

    def duplicated?(val)
      set_localization
      return false if localization_has_changed?
      translated_value =
        localization.read_attribute_before_type_cast('translated_value')
      if localization.is_changed? && !translated_value.nil?
        translated_value == val
      else
        localization.read_attribute_before_type_cast('default_value') == val
      end
    end

    private

    def set_localization
      return if locale.blank? || localization_key.blank?
      self.localization = localization_key.localizations
                                          .find_by(locale_id: locale_id)
    end

    def localization_has_changed?
      localization.blank? ||
        localization.is_deleted != localization_key_is_deleted
    end

    def update_existing_localization_data
      localization.update_attributes!(
        translated_value: translated_value,
        is_changed: true
      )
    end

    def update_existing_localization_key_data
      localization_key.update_attributes!(
        is_deleted: localization_key_is_deleted
      )
    end

    def assign_new_localization_data
      assign_new_locale unless locale.present?
      assign_new_localization_key unless localization_key.present?
      assign_new_localization unless localization.present?
    end

    def assign_new_locale
      self.locale = Lit::Locale.where(locale: locale_str).first_or_create
    end

    def assign_new_localization_key
      self.localization_key =
        Lit::LocalizationKey.where(
          localization_key: localization_key_str,
          is_deleted: localization_key_is_deleted
        ).first_or_create!
    end

    def assign_new_localization
      self.localization =
        Lit::Localization.where(localization_key_id: localization_key.id)
                         .where(locale_id: locale.id)
                         .first_or_initialize
      localization.translated_value = translated_value
      localization.is_changed = true
      localization.save!
    end

    def update_cache
      Lit.init.cache.update_cache localization.full_key,
                                  localization.translation
    end
  end
end
