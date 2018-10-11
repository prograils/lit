module Lit
  class LocalizationKey < ActiveRecord::Base
    attr_accessor :interpolated_key

    ## SCOPES
    scope :completed, proc { where(is_completed: true) }
    scope :not_completed, proc { where(is_completed: false) }
    scope :starred, proc { where(is_starred: true) }
    scope :ordered, proc { order('localization_key asc') }
    scope :after, proc { |dt|
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

    unless defined?(::ActionController::StrongParameters)
      ## ACCESSIBLE
      attr_accessible :localization_key
    end

    ## BEFORE & AFTER
    after_commit :check_completed, on: :update

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
      if new_created
        Lit::LocalizationKey.update_all ['is_completed=?', false], ['id=? and is_completed=?', id, false]
      end
    end

    def self.order_options
      ['localization_key asc', 'localization_key desc', 'created_at asc', 'created_at desc', 'updated_at asc', 'updated_at desc']
    end

    # it can be overridden in parent application, for example: {:order => "created_at desc"}
    def self.default_search_options
      {}
    end

    def self.search(options = {})
      options = options.to_h.reverse_merge(default_search_options).with_indifferent_access
      s = self
      if options[:order] && order_options.include?(options[:order])
        column, order = options[:order].split(' ')
        s = s.order(FakeLocalizationKey.arel_table[column.to_sym].send(order.to_sym))
      else
        s = s.ordered
      end
      localization_key_col = FakeLocalizationKey.arel_table[:localization_key]
      default_value_col = FakeLocalization.arel_table[:default_value]
      translated_value_col = FakeLocalization.arel_table[:translated_value]
      if options[:key_prefix].present?
        q = "#{options[:key_prefix]}%"
        s = s.where(localization_key_col.matches(q))
      end
      if options[:key].present?
        q = "%#{options[:key]}%"
        q_underscore = "%#{options[:key].parameterize.underscore}%"
        cond = localization_key_col.matches(q).or(
            default_value_col.matches(q).or(
                translated_value_col.matches(q)
            )
        ).or(localization_key_col.matches(q_underscore))
        s = s.joins([:localizations]).where(cond)
      end
      s
    end

    def change_all_completed
      self.class.transaction do
        toggle(:is_completed).save
        localizations.update_all is_changed: is_completed
      end
    end

    class FakeLocalizationKey < ActiveRecord::Base
      self.table_name = 'lit_localization_keys'
    end
    class FakeLocalization < ActiveRecord::Base
      self.table_name = 'lit_localizations'
    end

    private

    def check_completed
      self.is_completed = localizations.changed.count == localizations.count
      save! if is_completed_changed?
    end
  end
end
