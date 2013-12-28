module Lit
  class LocalizationKey < ActiveRecord::Base
    attr_accessor :interpolated_key

    ## SCOPES
    scope :completed, proc{ where(:is_completed=>true) }
    scope :not_completed, proc{ where(:is_completed=>false) }
    scope :starred, proc{ where(:is_starred=>true) }
    scope :ordered, proc{ order('localization_key asc') }
    scope :after, proc{|dt| where('updated_at >= ?', dt) }

    ## ASSOCIATIONS
    has_many :localizations, :dependent=>:destroy

    ## VALIDATIONS
    validates :localization_key,
              :presence=>true,
              :uniqueness=>{:if=>:localization_key_changed?}

    unless defined?(::ActionController::StrongParameters)
      ## ACCESSIBLE
      attr_accessible :localization_key
    end

    def to_s
      self.localization_key
    end

    def clone_localizations
      new_created = false
      Lit::Locale.find_each do |locale|
        self.localizations.where(:locale_id=>locale.id).first_or_create do |l|
          l.default_value = interpolated_key
          new_created = true
        end
      end
      if new_created
        Lit::LocalizationKey.update_all ['is_completed=?', false], ['id=? and is_completed=?', self.id, false]
      end
    end

    def mark_completed
      self.is_completed = self.localizations.changed.count(:id) == self.localizations.count
    end

    def mark_completed!
      self.save if self.mark_completed
    end

    def mark_all_completed!
      self.localizations.update_all(['is_changed=?', true])
      mark_completed!
    end

    def self.order_options
      ["localization_key asc", "localization_key desc", "created_at asc", "created_at desc"]
    end

    # it can be overridden in parent application, for example: {:order => "created_at desc"}
    def self.default_search_options
      {}
    end

    def self.search(options={})
      options = options.reverse_merge(default_search_options)
      s = self
      if options[:order] && order_options.include?(options[:order])
        column, order = options[:order].split(" ")
        s = s.order("#{Lit::LocalizationKey.quoted_table_name}.#{connection.quote_column_name(column)} #{order}" )
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
        cond = localization_key_col.matches(q).or(
            default_value_col.matches(q).or(
                translated_value_col.matches(q)
            )
        )
        s = s.joins([:localizations]).where(cond)
      end
      if not options[:include_completed].to_i==1
        s = s.not_completed
      end
      s
    end

  end
end
