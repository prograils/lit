module Lit
  class Locale < Base
    ## SCOPES
    scope :ordered, -> { order(locale: :asc) }
    scope :visible, -> { where(is_hidden: false) }

    ## ASSOCIATIONS
    has_many :localizations, dependent: :destroy

    ## VALIDATIONS
    validates :locale, presence: true, uniqueness: true

    ## BEFORE & AFTER
    after_save :reset_available_locales_cache
    after_destroy :reset_available_locales_cache

    ## ACCESSORS
    unless defined?(::ActionController::StrongParameters)
      attr_accessible :locale
    end

    def to_s
      locale
    end

    def translated_percentage
      total = all_localizations_count
      total > 0 ? (changed_localizations_count * 100 / total) : 0
    end

    def changed_localizations_count
      localizations.active.changed.count(:id)
    end

    def all_localizations_count
      localizations.active.count(:id)
    end

    private

    def reset_available_locales_cache
      return unless I18n.backend.respond_to?(:reset_available_locales_cache)
      I18n.backend.reset_available_locales_cache
    end
  end
end
