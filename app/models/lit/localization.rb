module Lit
  class Localization < ActiveRecord::Base

    ## SCOPES
    scope :changed, proc{ where(:is_changed=>true) }

    ## ASSOCIATIONS
    belongs_to :locale
    belongs_to :localization_key

    ## VALIDATIONS
    validates :locale_id,
              :presence=>true

    if ::Rails::VERSION::MAJOR<4
      ## ACCESSIBLE
      attr_accessible :translated_value, :locale_id
    end

    ## BEFORE & AFTER
    before_update :update_is_changed
    after_update :mark_localization_key_completed

    def to_s
      self.value
    end

    def full_key
      "#{self.locale.locale}.#{self.localization_key.localization_key}"
    end

    def get_value
      is_changed? ? self.translated_value : self.default_value
    end

    private
      def update_is_changed
        self.is_changed = true unless is_changed?
      end

      def mark_localization_key_completed
        self.localization_key.mark_completed!
      end
  end
end
