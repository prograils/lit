# frozen_string_literal: true

require 'test_helper'

class ExportTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    I18n.backend.reset_available_locales_cache
  end

  test 'exports all locales to yaml when locale keys not specified' do
    yaml = Lit::Export.call(locale_keys: [], format: :yaml)
    parsed_yaml = YAML.load(yaml)
    assert(parsed_yaml.keys.sort ==
      Lit::Localization.joins(:locale).distinct.pluck('locale').sort)
  end

  test 'exports selected locales to yaml when locale keys specified' do
    yaml = Lit::Export.call(locale_keys: %i[en], format: :yaml)
    parsed_yaml = YAML.load(yaml)
    assert parsed_yaml.keys == %w[en]
  end

  test 'exports all locales to csv when locale keys not specified' do
    csv = Lit::Export.call(locale_keys: [], format: :csv)
    parsed_csv = CSV.parse(csv)
    header = parsed_csv.delete_at(0)
    assert(%w[en pl].all? { |l| header.include?(l) })
    assert(parsed_csv.map(&:first).uniq.sort ==
           Lit::Localization.joins(:localization_key)
           .pluck(:localization_key).uniq.sort)
  end

  test 'exports selected locales to csv when locale keys specified' do
    csv = Lit::Export.call(locale_keys: [:en], format: :csv)
    parsed_csv = CSV.parse(csv)
    header = parsed_csv.delete_at(0)
    assert(header.include?('en'))
    assert(header.exclude?('pl'))
  end

  test 'exports arrays as series of rows' do
    csv = Lit::Export.call(locale_keys: [], format: :csv)
    parsed_csv = CSV.parse(csv)
    assert(parsed_csv.select { |row| row.first == 'scopes.array' }.
           map(&:second) == I18n.t('scopes.array'))
  end

  test 'skips keys marked as deleted' do
    Lit::LocalizationKey.find_by(localization_key: 'scopes.string').update!(is_deleted: true)
    csv = Lit::Export.call(locale_keys: [], format: :csv)
    parsed_csv = CSV.parse(csv)
    assert parsed_csv.map(&:first).exclude?('scopes.string')
  end
end
