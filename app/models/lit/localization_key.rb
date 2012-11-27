module Lit
  class LocalizationKey < ActiveRecord::Base

    ## ASSOCIATIONS
    has_many :localizations, :dependent=>:destroy

    ## VALIDATIONS
    validates :localization_key,
              :presence=>true,
              :uniqueness=>true

    ## ACCESSIBLE
    attr_accessible :localization_key

    def to_s
      self.localization_key
    end

    def clone_localizations
      first_localization = self.localizations.first
      Lit::Locale.find_each do |locale|
        self.localizations.where(:locale_id=>locale.id).first_or_create do |l|
          l.default_value = first_localization.get_value
        end
      end
    end
  end
end
