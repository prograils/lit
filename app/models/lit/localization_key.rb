module Lit
  class LocalizationKey < ActiveRecord::Base
    attr_accessor :interpolated_key

    ## SCOPES
    scope :completed, -> { where(is_completed: true) }
    scope :not_completed, -> { where(is_completed: false) }
    scope :starred, -> { where(is_starred: true) }
    scope :ordered, -> { order(localization_key: :asc) }
    scope :after, lambda { |dt|
      joins(:localizations)
        .where('lit_localization_keys.updated_at >= ?', dt)
        .where('lit_localizations.is_changed = true')
    }

    ## ASSOCIATIONS
    has_many :localizations, dependent: :destroy

    ## VALIDATIONS
    validates :localization_key,
              presence: true,
              uniqueness: { if: :localization_key_changed? }

    ## ACCESSORS
    unless defined?(::ActionController::StrongParameters)
      attr_accessible :localization_key
    end

    def to_s
      localization_key
    end

    def clone_localizations
      new_created = false
      Lit::Locale.find_each do |locale|
        localizations.where(locale_id: locale.id).first_or_create do |l|
          l.default_value = interpolated_key
          new_created = true
        end
      end
      return unless new_created
      Lit::LocalizationKey.update_all ['is_completed=?', false],
                                      ['id=? and is_completed=?', id, false]
    end

    def mark_completed
      self.is_completed = localizations.changed.count(:id) == localizations.count
    end

    def mark_completed!
      save if mark_completed
    end

    def mark_all_completed!
      localizations.update_all(['is_changed=?', true])
      mark_completed!
    end

    def self.order_options
      ['localization_key asc', 'localization_key desc', 'created_at asc',
       'created_at desc', 'updated_at asc', 'updated_at desc']
    end

    # it can be overridden in parent application,
    # for example: {:order => "created_at desc"}
    def self.default_search_options
      {}
    end

    def self.search(options = {})
      LocalizationKeySearchQuery.new(self, options).perform
    end
  end
end
