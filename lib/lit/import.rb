require 'csv'

module Lit
  class Import
    class << self
      def call(*args)
        new(*args).perform
      end
    end

    attr_reader :input, :locale_keys, :format, :skip_nil

    def initialize(input:, locale_keys: [], format:, skip_nil: true, dry_run: false, raw: false)
      raise ArgumentError, 'format must be yaml or csv' if %i[yaml csv].exclude?(format.to_sym)
      @input = input
      @locale_keys = locale_keys.presence || I18n.available_locales
      @format = format
      @skip_nil = skip_nil
      @dry_run = dry_run
      @raw = raw
    end

    def perform
      send(:"import_#{format}")
    end

    private

    def import_yaml
      validate_yaml
      locale_keys.each do |locale|
        I18n.with_locale(locale) do
          yml = parsed_yaml[locale.to_s]
          Hash[*Lit::Cache.flatten_hash(yml)].each do |key, default_translation|
            next if default_translation.nil? && skip_nil
            upsert(locale, key, default_translation)
          end
        end
      end
    rescue Psych::SyntaxError => e
      raise ArgumentError, "Invalid YAML file: #{e.message}", cause: e
    end

    def import_csv
      validate_csv
      processed_csv = preprocess_csv

      processed_csv.each do |row|
        key = row.first
        row_translations = Hash[locales_in_csv.zip(row.drop(1))]
        row_translations.each do |locale, value|
          next unless locale_keys.blank? || locale_keys.map(&:to_sym).include?(locale.to_sym)
          next if value.nil? && skip_nil
          upsert(locale, key, value)
        end
      end
    rescue CSV::MalformedCSVError => e
      raise ArgumentError, "Invalid CSV file: #{e.message}", cause: e
    end

    def validate_yaml
      errors = []

      # YAML.load can return false, hence not using #empty?
      errors << :yaml_is_empty if parsed_yaml.blank?

      if parsed_yaml.present? &&
         (locale_keys.map(&:to_sym) - parsed_yaml.keys.map(&:to_sym)).any?
        errors << :not_all_requested_locales_included_in_header
      end

      fail ArgumentError, errors.map { |e| e.to_s.humanize }.to_sentence if errors.any?
    end

    def validate_csv # rubocop:disable Metrics/AbcSize
      errors = []

      # CSV may not be empty
      errors << :csv_is_empty if parsed_csv.empty?

      # verify CSV header
      if !parsed_csv.empty? &&
         (locale_keys.map(&:to_s) - parsed_csv[0].drop(1)).any?
        errors << :not_all_requested_locales_included_in_header
      end

      # any further checks that we at some time think of should fall here

      fail ArgumentError, errors.map { |e| e.to_s.humanize }.to_sentence if errors.any?
    end

    # the main task of this routine is to replace blanks with nils (in CSV it cannot be distinguished,
    # so in order for :skip_nil option to work as intended blanks must be treated as nil);
    # as well as that, we need to look for multiple occurrences of certain keys and merge them
    # into arrays
    def preprocess_csv
      concatenate_arrays(replace_blanks(parsed_csv))
    end

    def parsed_csv
      @parsed_csv ||=
        begin
          CSV.parse(input)
        rescue CSV::MalformedCSVError
          # Some Excel versions tend to save CSVs with columns separated with tabs instead
          # of commas. Let's try that out if needed.
          CSV.parse(input, col_sep: "\t")
        end
    end

    def parsed_yaml
      @parsed_yaml ||= YAML.load(input)
    end

    def locales_in_csv
      @locales_in_csv ||= parsed_csv.first.drop(1)
    end

    # This is mean to insert a value for a key in a given locale
    # using some kind of strategy which depends on the service's options.
    #
    # For instance, when @raw option is true (it's the default),
    # if a key already exists, it overrides the default_value of the
    # existing localization key; otherwise, with @raw set to false,
    # it keeps the default as it is and, no matter if a translated value
    # is there, translated_value is overridden with the imported one
    # and is_changed is set to true.
    def upsert(locale, key, value) # rubocop:disable Metrics/MethodLength
      I18n.with_locale(locale) do
        # when an array has to be inserted with a default value, it needs to
        # be done like:
        # I18n.t('foo', default: [['bar', 'baz']])
        # because without the double array, array items are treated as fallback keys
        # - then, the last array element is the final fallback; so in this case we
        # don't specify fallback keys and only specify the final fallback, which
        # is the array
        val = value.is_a?(Array) ? [value] : value
        I18n.t(key, default: val)
        unless @raw
          # this indicates that this translation already exists
          existing_translation =
            Lit::Localization.joins(:locale, :localization_key)
                             .find_by('localization_key = ? and locale = ?',
                                      key, locale)
          if existing_translation
            existing_translation.update(translated_value: value, is_changed: true)
            lkey = existing_translation.localization_key
            lkey.update(is_deleted: false) if lkey.is_deleted
          end
        end
      end
    end

    def concatenate_arrays(csv) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/LineLength
      csv.inject([]) do |accu, row|
        if row.first == accu.last&.first # equal keys
          accu.tap do
            accu[-1] = [
              row.first,
              *accu[-1].drop(1)
                       .map { |x| Array.wrap(x).presence || [x] }
                       .zip(row.drop(1)).map(&:flatten)
            ]
          end
        else
          accu << row
        end
      end
    end

    def replace_blanks(csv)
      csv.drop(1).each do |row|
        row.replace(row.map(&:presence))
      end
    end
  end
end
