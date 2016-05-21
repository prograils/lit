# encoding: utf-8
require 'test_helper'

class WelcomeTest < ActionDispatch::IntegrationTest
  def setup
    @old_fallback = Lit.fallback
    @old_humanize_key = Lit.humanize_key
  end

  def teardown
    Lit.fallback = @old_fallback
    Lit.humanize_key = @old_humanize_key
  end

  test "should properly display 'Hello world' in english" do
    visit('/en/welcome')
    assert page.has_content?('Hello World')
  end

  test 'should properly display text without default and humanize=false' do
    Lit.humanize_key = false
    Lit.fallback = false
    visit('/en/welcome')
    assert page.has_content?('Text Without Default')
    visit('/pl/welcome')
    assert page.has_content?('Text Without Default')
  end

  test 'should properly display text without default and humanize=true' do
    Lit.humanize_key = true
    Lit.fallback = false
    visit('/en/welcome')
    assert page.has_content?('Text without default')
    visit('/pl/welcome')
    assert page.has_content?('Text without default')
  end

  test 'should properly display text with default' do
    Lit.humanize_key = false
    Lit.fallback = false
    visit('/en/welcome')
    assert page.has_content?('Default content')
    visit('/pl/welcome')
    assert page.has_content?('Default content')
  end

  test 'should properly display saturday abbr in polish' do
    visit('/pl/welcome')
    assert page.has_content?('Sob')
  end

  test 'should use interpolation instead of default value' do
    Lit.humanize_key = false
    Lit.fallback = false
    visit('/pl/welcome')
    assert page.has_content?('Abrakadabra dwa kije')
    visit('/en/welcome')
    assert page.has_content?('Some Strange Key')
  end

  test "should properly display 'Hello world' in polish" do
    visit('/pl/welcome')
    assert page.has_content?('Witaj świecie')
  end

  test "should properly display 'Hello world' in polish after change" do
    visit('/pl/welcome')
    locale = Lit::Locale.find_by_locale!('pl')
    localization_key = Lit::LocalizationKey.find_by_localization_key!('scope.hello_world')
    localization = Lit::Localization.find_by_locale_id_and_localization_key_id!(locale.id, localization_key.id)
    text = localization.get_value
    assert text.present?

    assert page.has_content?(text)
    text = 'Żegnaj okrutny świecie'
    localization.translated_value = text
    localization.save!
    localization.update_column :is_changed, true
    Lit.init.cache.refresh_key(localization.full_key)
    visit('/pl/welcome')
    localization.reload
    assert page.has_content?(text)
  end

  test 'should not fallback if not asked to' do
    Lit.humanize_key = false
    Lit.fallback = false
    visit('/en/welcome')
    assert page.has_content?('English translation')
    visit('/pl/welcome')
    assert page.has_content?('Text With Translation In English')
  end

  test 'should properly fallback' do
    Lit.fallback = true
    visit('/en/welcome')
    assert page.has_content?('English translation')
    visit('/pl/welcome')
    assert page.has_content?('English translation')
  end
end
