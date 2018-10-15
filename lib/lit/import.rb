require 'csv'

module Lit
  class Import
    class << self
      def call(*args)
        new(*args).perform
      end
    end

    attr_reader :input, :locale_keys, :format, :skip_nil

    def initialize(input:, locale_keys: [], format:, skip_nil: true, dry_run: false)
      raise ArgumentError, "format must be yaml or csv" if %i[yaml csv].exclude?(format)
      @input = input
      @locale_keys = locale_keys
      @format = format
      @skip_nil = skip_nil
      @dry_run = dry_run
    end

    def perform
      send(:"import_#{format}")
    end

    private

    def import_yaml
      full_yml = YAML.load(input)
      locale_keys.each do |locale|
        I18n.with_locale(locale) do
          yml = full_yml[locale.to_s]
          Hash[*Lit::Cache.flatten_hash(yml)].each do |key, default_translation|
            next if default_translation.nil? && skip_nil
            puts key
            I18n.t(key, default: default_translation)
          end
        end
      end
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
          puts key
          I18n.with_locale(locale) do
            I18n.t(key, default: value)
          end
        end
      end
    rescue CSV::MalformedCSVError => e
      raise ArgumentError, "Invalid CSV file: #{e.message}", cause: e
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

    def locales_in_csv
      @locales_in_csv ||= parsed_csv.first.drop(1)
    end

    private

    def concatenate_arrays(csv)
      csv.inject([]) do |accu, row|
        if row.first == accu.last&.first # equal keys
          accu.tap do
            accu[-1] = [
              row.first,
              *accu[-1].drop(1).map { |x| Array.wrap(x) }.zip(row.drop(1)).map(&:flatten)
            ]
          end
        else
          accu << row
        end
      end
    end

    def replace_blanks(csv)
      csv.drop(1).each do |row|
        row.replace(row.map { |cell| cell.presence })
      end
    end
  end
end