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
  end
end
