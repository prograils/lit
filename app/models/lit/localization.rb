module Lit
  class Localization < Lit::Base
    serialize :translated_value
    serialize :default_value

    ## SCOPES
    scope :changed, -> { where is_changed: true }
    scope :not_changed, -> { where is_changed: false }

    # @HACK: dirty, find a way to round date to full second
    scope :after, ->(dt) { where("updated_at >= ?", dt + 1.second).where(is_changed: true) }
    scope :active, -> { joins(:localization_key).where(Lit::LocalizationKey.table_name => {is_deleted: false}) }

    ## ASSOCIATIONS
    belongs_to :locale, required: true
    belongs_to :localization_key, touch: true, required: true
    has_many :localization_versions, dependent: :destroy
    has_many :versions, class_name: "::Lit::LocalizationVersion"

    ## DELEGATIONS
    delegate :is_deleted, to: :localization_key

    ## VALIDATIONS
    validates :locale, :localization_key, presence: true

    ## ACCESSORS
    attr_accessor :full_key_str

    attr_accessible :translated_value, :locale_id unless defined?(::ActionController::StrongParameters)

    ## BEFORE & AFTER
    with_options if: :translated_value_changed? do |o|
      o.before_update :create_version
    end
    after_commit :update_cache, on: :update

    def to_s
      translation
    end

    def full_key
      full_key_str || [locale.locale, localization_key.localization_key].join(".")
    end

    def translation
      (is_changed? && !translated_value.nil?) ? translated_value : default_value
    end

    def value
      translation
    end

    def localization_key_str
      localization_key.localization_key
    end

    def localization_key_is_deleted
      localization_key.is_deleted
    end

    def locale_str
      locale.locale
    end

    def last_change
      updated_at.to_fs(:db)
    end

    def update_default_value(value)
      return true if persisted? && default_value == value

      if persisted?
        update(default_value: value)
      else
        self.default_value = value
        save!
      end
    end

    private

    def update_cache
      Lit.init.cache.update_cache full_key, translation
    end

    def create_version
      return if translated_value.blank?

      translated_value = translated_value_was || default_value
      localization_versions.new(translated_value:)
    end
  end
end
