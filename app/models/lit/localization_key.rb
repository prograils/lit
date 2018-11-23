module Lit
  class LocalizationKey < Lit::Base
    attr_accessor :interpolated_key

    ## SCOPES
    scope :completed, -> { where(is_completed: true) }
    scope :not_completed, -> { where(is_completed: false) }
    scope :starred, -> { where(is_starred: true) }
    scope :ordered, -> { order(localization_key: :asc) }
    scope :active, -> { where(is_deleted: false) }
    scope :not_active, -> { where(is_deleted: true) }
    scope :visited_again, -> { where(is_visited_again: true) }
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

    ## BEFORE AND AFTER
    after_commit :check_completed, on: :update
    after_commit :remove_from_cache, on: :destroy

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

    def change_all_completed
      self.class.transaction do
        toggle(:is_completed).save!
        localizations.update_all is_changed: is_completed
      end
    end

    def soft_destroy
      ActiveRecord::Base.transaction do
        update is_deleted: true
        change_all_completed
        remove_from_cache
      end
    end

    def remove_from_cache
      Lit::Locale.pluck(:locale).each do |l|
        Lit.init.cache.delete_key "#{l}.#{localization_key}"
      end
    end

    def restore
      ActiveRecord::Base.transaction do
        update is_deleted: false, is_completed: false, is_visited_again: false
        localizations.update_all is_changed: false
      end
    end

    private

    def check_completed
      self.is_completed = localizations.changed.count == localizations.count
      save! if is_completed_changed?
    end

    def lit_attribute_will_change
      localization_key_will_change!
    end
  end
end
