module Lit
  class Locale < ActiveRecord::Base

    ## SCOPES
    scope :ordered, proc{ order('locale ASC') }
    scope :visible, proc{ where(:is_hidden=>false) }

    ## ASSOCIATIONS
    has_many :localizations, :dependent=>:destroy

    ## VALIDATIONS
    validates :locale,
              :presence=>true,
              :uniqueness=>true

    if ::Rails::VERSION::MAJOR<4
      ## ACCESSIBLE
      attr_accessible :locale
    end

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
