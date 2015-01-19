module Lit
  class Localization < ActiveRecord::Base
    serialize :translated_value
    serialize :default_value

    ## SCOPES
    scope :changed, proc { where(is_changed: true) }
    # @HACK: dirty, find a way to round date to full second
    scope :after, proc { |dt| where('updated_at >= ?', dt + 1.second) }
    scope :without_translation, proc { where(translated_value: nil)}

    ## ASSOCIATIONS
    belongs_to :locale
    belongs_to :localization_key, touch: true
    has_many :localization_versions, dependent: :destroy
    has_many :versions, class_name: '::Lit::LocalizationVersion'

    ## VALIDATIONS
    validates :locale_id,
              presence: true

    unless defined?(::ActionController::StrongParameters)
      ## ACCESSIBLE
      attr_accessible :translated_value, :locale_id
    end

    ## BEFORE & AFTER
    with_options if: :translated_value_changed? do |o|
      o.before_update :update_is_changed_attribute
      o.before_update :create_version
    end
    after_update :mark_localization_key_completed

    def to_s
      get_value
    end

    def full_key
      [locale.locale, localization_key.localization_key].join('.')
    end

    def get_value
      (is_changed? && (!translated_value.nil?)) ? translated_value : default_value
    end

    def value
      get_value
    end

    def localization_key_str
      localization_key.localization_key
    end

    def locale_str
      locale.locale
    end

    def last_change
      updated_at.to_s(:db)
    end

    def update_default_value(value)
      return true if persisted? && default_value == value
      self.default_value = value
      self.save!
    end

    private

    def update_is_changed_attribute
      return if attributes['is_changed'] == true

      self[:is_changed] = true
      @should_mark_localization_key_completed = true
    end

    def mark_localization_key_completed
      localization_key.mark_completed! if @should_mark_localization_key_completed
    end

    def create_version
      if translated_value.present?
        l = localization_versions.new
        l.translated_value = translated_value_was || default_value
      end
    end
  end
end
