# frozen_string_literal: true

require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    I18n.backend.reset_available_locales_cache
  end

  # actually the formats we consider are CSV and YAML, but let's also ensure
  # a tab-separated (TSV) file as opposed to comma-separated (CSV) one is also
  # correctly imported
  %i[csv tsv yaml].each do |format|
    test "imports from #{format}" do
      ext = format == :yaml ? 'yml' : format.to_s
      parsing_format = format == :tsv ? 'csv' : format.to_s
      input = imported_file("import.#{ext}.normal")
      Lit::Import.call(input: input, format: parsing_format)
      verify_foo_key
    end
  end

  %i[csv yaml].each do |format|
    ext = format == :yaml ? 'yml' : format.to_s

    test "raises ArgumentError when file is empty (#{format})" do
      input = ''
      assert_raise ArgumentError do
        Lit::Import.call(input: input, format: format)
      end
    end

    test 'does not override existing default or translated localization ' \
         "values in raw mode (#{format})" do
      input = imported_file("import.#{ext}.normal")
      I18n.with_locale(:en) { I18n.t('scopes.foo', default: 'bar') }
      I18n.with_locale(:pl) { I18n.t('scopes.foo', default: 'baz') }
      Lit::Localization.find_by(default_value: 'baz')
                       .update(translated_value: 'bazzz')

      Lit::Import.call(input: input, format: format, raw: true)
      foo_key_localizations =
        Lit::LocalizationKey.find_by(localization_key: 'scopes.foo')
                            .localizations.joins(:locale)

      pl_loc = foo_key_localizations.find_by("locale = 'pl'")
      assert(pl_loc.translated_value == 'bazzz')
      assert(pl_loc.default_value == 'baz')
      assert(
        foo_key_localizations.find_by("locale = 'en'").default_value == 'bar'
      )
    end

    test 'sets translated values over existing default and translated ' \
         "localization values in non-raw mode (#{format})" do
      input = imported_file("import.#{ext}.normal")
      I18n.with_locale(:en) { I18n.t('scopes.foo', default: 'bar') }
      I18n.with_locale(:pl) { I18n.t('scopes.foo', default: 'baz') }
      Lit::Localization.find_by(default_value: 'baz')
                       .update(translated_value: 'bazzz')
      Lit::Import.call(input: input, format: format, raw: false)

      foo_key_localizations =
        Lit::LocalizationKey.find_by(localization_key: 'scopes.foo')
                            .localizations.joins(:locale)

      pl_localization = foo_key_localizations.find_by("locale = 'pl'")
      en_localization = foo_key_localizations.find_by("locale = 'en'")
      assert(pl_localization.translated_value == 'foo pl')
      assert(pl_localization.is_changed?)
      assert(en_localization.translated_value == 'foo en')
      assert(en_localization.is_changed?)

      bar_key_localizations =
        Lit::LocalizationKey.find_by(localization_key: 'scopes.bar').localizations.joins(:locale)
      pl_localization = bar_key_localizations.find_by("locale = 'pl'")
      en_localization = bar_key_localizations.find_by("locale = 'en'")
      assert(pl_localization.default_value == 'bar pl')
      assert(pl_localization.translated_value == 'bar pl')
      assert(pl_localization.is_changed?)
      assert(en_localization.default_value == 'bar en')
      assert(en_localization.translated_value == 'bar en')
      assert(pl_localization.is_changed?)
    end

    test "imports specified languages (#{format})" do
      input = imported_file("import.#{ext}.normal")
      Lit::Import.call(input: input, format: format, locale_keys: %i[en])
      verify_foo_key(languages: %w[en])
    end

    test 'raises ArgumentError when file does not contain one of ' \
         "requested locales (#{format})" do
      input = imported_file("import.#{ext}.missing-locale")
      assert_raise ArgumentError do
        Lit::Import.call(input: input, locale_keys: %i[en es], format: format)
      end
    end

    test "raises ArgumentError when file is malformed (#{format})" do
      input = imported_file("import.#{ext}.malformed")
      assert_raise ArgumentError do
        Lit::Import.call(input: input, format: format.to_s)
      end
    end

    test "imports arrays (#{format})" do
      input = imported_file("import.#{ext}.array")
      Lit::Import.call(input: input, format: format.to_s)
      verify_array
    end

    test "imports nil values when SKIP_NIL option is not set (#{format})" do
      input = imported_file("import.#{ext}.nil")
      I18n.with_locale(:en) { I18n.t('scopes.to_be_nil', default: 'bar') }
      Lit::Import.call(input: input, format: format.to_s,
                       raw: false, skip_nil: false)
      localizations =
        Lit::LocalizationKey.find_by(localization_key: 'scopes.to_be_nil')
                            .localizations
                            .joins(:localization_key, :locale)
      nil_localizations =
        localizations.where("localization_key = 'scopes.to_be_nil'")
      # the existing localization should remain in place; the new, nil-value
      # one should be imported
      assert(nil_localizations.map(&:locale).map(&:locale).sort == %w[en pl])
      assert(nil_localizations.map(&:translated_value).all?(&:nil?))
    end

    test "does not import nil values when SKIP_NIL option is set (#{format})" do
      input = imported_file("import.#{ext}.nil")
      I18n.with_locale(:en) { I18n.t('scopes.to_be_nil', default: 'bar') }
      Lit::Import.call(input: input, format: format.to_s,
                       raw: false, skip_nil: true)
      localizations =
        Lit::LocalizationKey.find_by(localization_key: 'scopes.to_be_nil')
                            .localizations
                            .joins(:localization_key, :locale)
      nil_key_localizations =
        localizations.where("localization_key = 'scopes.to_be_nil'")
      # expect that the empty localization is not imported at all
      assert(nil_key_localizations.map(&:locale).map(&:locale) == %w[en])
    end

    test "resets is_deleted flag for existing deleted localization keys (#{format})" do
      input = imported_file("import.#{ext}.normal")
      I18n.with_locale(:en) { I18n.t('scopes.foo', default: 'bar') }
      foo_key = Lit::LocalizationKey.find_by(localization_key: 'scopes.foo')
      foo_key.update!(is_deleted: true)
      Lit::Import.call(input: input, format: format, raw: false)
      assert !foo_key.reload.is_deleted
    end
  end

  test "imports from csv preserving nil values in arrays" do
    input = imported_file('import.csv.array_with_nil')
    Lit::Import.call(input: input, format: 'csv')
    new_localization_key =
      Lit::LocalizationKey.find_by(localization_key: 'scopes.csvarray')
      localization = lambda do |locale|
        new_localization_key
          .localizations
          .joins(:locale)
          .find_by(lit_locales: { locale: locale })
      end
      assert_equal(
        localization.call('en').translated_value,
        [nil, 'val0 en', 'val1 en', nil, 'val3 en']
      )
      assert_equal(
        localization.call('pl').translated_value,
        [nil, 'val0 pl', 'val1 pl', 'val2 pl', nil]
      )

  end

  def imported_file(name)
    File.read(Lit::Engine.root.join('test', 'fixtures', 'lit', 'files', name))
  end

  def verify_foo_key(languages: %w[en pl]) # rubocop:disable Metrics/MethodLength, Metrics/LineLength
    new_localization_key =
      Lit::LocalizationKey.find_by(localization_key: 'scopes.foo')
    assert new_localization_key.present?
    assert(
      languages.all? do |loc|
        new_localization_key.localizations.map(&:locale)
                            .map(&:locale).include?(loc)
      end
    )
    assert(
      languages.all? do |loc|
        new_localization_key.localizations.map(&:value).include?("foo #{loc}")
      end
    )
  end

  def verify_array
    new_localization_key =
      Lit::LocalizationKey.find_by(localization_key: 'scopes.csvarray')
    assert new_localization_key.present?
    assert(
      new_localization_key.localizations.all? do |l|
        l.value.is_a?(Array) && l.value.length == 4
      end
    )
  end
end
