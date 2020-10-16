# frozen_string_literal: true

require 'test_helper'

class ExportTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    I18n.backend.reset_available_locales_cache
    Lit.init.cache.instance_variable_get(:@hits_counter).clear
    Lit.init.cache.instance_variable_get(:@hits_counter).clear
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

  test 'exports nested keys to yaml properly even when localization is present for root key' do
    yaml = Lit::Export.call(locale_keys: %i[en], format: :yaml)
    parsed_yaml = YAML.load(yaml)
    nested_part = parsed_yaml['en']['scopes']['hash']
    assert nested_part.is_a?(Hash)
    assert nested_part.key?('sub_one')
    assert nested_part.key?('sub_two')
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

  test 'includes hits count if specified' do
    seen_lk = Lit::LocalizationKey.find_by(localization_key: 'scopes.string')
    unseen_lk = Lit::LocalizationKey.find_by(localization_key: 'scopes.array')
    10.times { I18n.t(seen_lk.localization_key) }
    csv = Lit::Export.call(locale_keys: [], format: :csv, include_hits_count: true)
    parsed_csv = CSV.parse(csv)
    assert parsed_csv.find { |row| row.first == seen_lk.localization_key }.last.to_i == 10
    assert parsed_csv.find { |row| row.first == unseen_lk.localization_key }.last.to_i == 0
  end
end
