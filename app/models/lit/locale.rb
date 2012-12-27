module Lit
  class Locale < ActiveRecord::Base

    ## SCOPES
    scope :ordered, order('locale ASC')

    ## ASSOCIATIONS
    has_many :localizations, :dependent=>:destroy

    ## VALIDATIONS
    validates :locale,
              :presence=>true,
              :uniqueness=>true

    ## ACCESSIBLE
    attr_accessible :locale

    def to_s
      self.locale
    end

    def get_translated_percentage
      self.get_changed_localizations_count * 100 / self.get_all_localizations_count
    end

    def get_changed_localizations_count
      self.localizations.changed.count(:id)
    end

    def get_all_localizations_count
      self.localizations.count(:id)
    end
  end
end
