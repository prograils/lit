# frozen_string_literal: true

require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    Lit.init.cache.reset
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test 'imports from csv separated by commas' do
    input = imported_file('import.csv')
    Lit::Import.call(input: input, format: :csv)
    verify_foo_key
  end

  test 'imports from tsv separated by tabs' do
    input = imported_file('import.tsv')
    Lit::Import.call(input: input, format: :csv)
    verify_foo_key
  end

  test 'raises ArgumentError when file is empty' do
    input = ''
    assert_raise ArgumentError do
      Lit::Import.call(input: input, format: :csv)
    end
  end

  test 'raises ArgumentError when file does not contain one of requested locales' do
    input = imported_file('import.missing-locale.csv')
    assert_raise ArgumentError do
      Lit::Import.call(input: input, locale_keys: %i[en es], format: :csv)
    end
  end

  test 'raises ArgumentError when file is malformed' do
    input = imported_file('import.malformed.csv')
    assert_raise ArgumentError do
      Lit::Import.call(input: input, format: :csv)
    end
  end

  test 'imports specified languages' do
    input = imported_file('import.csv')
    Lit::Import.call(input: input, format: :csv, locale_keys: %i[en])
    verify_foo_key(languages: %w[en])
  end

  test 'imports array from consecutive rows' do
    input = imported_file('import.array.csv')
    Lit::Import.call(input: input, format: :csv)
    verify_array
  end

  test 'overrides existing localization values' do
    input = imported_file('import.csv')
    I18n.with_locale(:en) { I18n.t('scopes.foo', default: 'bar') }
    I18n.with_locale(:pl) { I18n.t('scopes.foo', default: 'baz') }
    Lit::Import.call(input: input, format: :csv)
    foo_key_localizations =
      Lit::LocalizationKey.find_by(localization_key: 'scopes.foo').localizations.joins(:locale)

    # TODO: Should it become default_value or translated_value?!
    assert(foo_key_localizations.find_by("locale = 'pl'").value == 'foo pl')
    assert(foo_key_localizations.find_by("locale = 'en'").value == 'foo en')
  end

  def imported_file(name)
    File.read(Lit::Engine.root.join('test', 'fixtures', 'lit', 'files', name))
  end

  def verify_foo_key(languages: %w[en pl]) # rubocop:disable Metrics/MethodLength
    new_localization_key = Lit::LocalizationKey.find_by(localization_key: 'scopes.foo')
    assert new_localization_key.present?
    assert(
      languages.all? do |loc|
        new_localization_key.localizations.map(&:locale).map(&:locale).include?(loc)
      end
    )
    assert(
      languages.all? do |loc|
        new_localization_key.localizations.map(&:value).include?("foo #{loc}")
      end
    )
  end

  def verify_array
    new_localization_key = Lit::LocalizationKey.find_by(localization_key: 'scopes.csvarray')
    assert new_localization_key.present?
    assert(
      new_localization_key.localizations.all? do |l|
        l.value.is_a?(Array) && l.value.length == 4
      end
    )
  end
end
