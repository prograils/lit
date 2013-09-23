module Lit
  class Localization < ActiveRecord::Base
    serialize :translated_value
    serialize :default_value

    ## SCOPES
    scope :changed, proc{ where(:is_changed=>true) }
    scope :after, proc{|dt| where('updated_at >= ?', dt) }

    ## ASSOCIATIONS
    belongs_to :locale
    belongs_to :localization_key
    has_many :localization_versions, dependent: :destroy
    has_many :versions, class_name: '::Lit::LocalizationVersion'

    ## VALIDATIONS
    validates :locale_id,
              :presence=>true

    unless defined?(::ActionController::StrongParameters)
      ## ACCESSIBLE
      attr_accessible :translated_value, :locale_id
    end

    ## BEFORE & AFTER
    before_update :update_is_changed
    before_update :create_version
    after_update :mark_localization_key_completed

    def to_s
      self.get_value
    end

    def full_key
      "#{self.locale.locale}.#{self.localization_key.localization_key}"
    end

    def get_value
      (is_changed? && (not self.translated_value.nil?)) ? self.translated_value : self.default_value
    end

    def value
      get_value
    end

    def localization_key_str
      self.localization_key.localization_key
    end

    def locale_str
      self.locale.locale
    end

    def last_change
      self.updated_at.to_s(:db)
    end

    private
      def update_is_changed
        self.is_changed = true unless is_changed?
      end

      def mark_localization_key_completed
        self.localization_key.mark_completed!
      end

      def create_version
        if self.translated_value.present? and (not self.translated_value.nil?)
          l = self.localization_versions.new
          l.translated_value = self.translated_value_was || self.default_value
        end
      end
  end
end
