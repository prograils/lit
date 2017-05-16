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
        s = s.order("#{Lit::LocalizationKey.quoted_table_name}.#{connection.quote_column_name(column)} #{order}")
      else
        s = s.ordered
      end
      localization_key_col = Lit::LocalizationKey.arel_table[:localization_key]
      default_value_col = Lit::Localization.arel_table[:default_value]
      translated_value_col = Lit::Localization.arel_table[:translated_value]
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
      unless options[:include_completed].to_i == 1
        s = s.not_completed
      end
      s
    end
  end
end
