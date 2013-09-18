# encoding: utf-8
require 'test_helper'

class WelcomeTest < ActionDispatch::IntegrationTest

  test "should properly display 'Hello world' in english" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/en/welcome')
    assert page.has_content?('Hello World')
  end

  test "should properly display text without default" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/en/welcome')
    assert page.has_content?('Text without default')
    visit('/pl/welcome')
    assert page.has_content?('Text without default')
  end

  test "should properly display text with default" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/en/welcome')
    Lit.init.logger.info page.body
    assert page.has_content?('Default content')
    visit('/pl/welcome')
    assert page.has_content?('Default content')
  end

  test "should properly display saturday abbr in polish" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/pl/welcome')
    assert page.has_content?('Sob')
  end

  test "should use interpolation instead of default value" do
    Lit.fallback = false
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/pl/welcome')
    assert page.has_content?('Abrakadabra dwa kije')
    visit('/en/welcome')
    assert page.has_content?('Some strange key')
  end

  test "should properly display 'Hello world' in polish" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/pl/welcome')
    assert page.has_content?('Witaj świecie')
  end

  test "should properly display 'Hello world' in polish after change" do
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/pl/welcome')
    locale = Lit::Locale.find_by_locale!('pl')
    localization_key = Lit::LocalizationKey.find_by_localization_key!('scope.hello_world')
    localization = Lit::Localization.find_by_locale_id_and_localization_key_id!(locale.id, localization_key.id)
    text = localization.get_value
    assert page.has_content?(text)
    text ='Żegnaj okrutny świecie'
    localization.translated_value = text
    localization.save!
    Lit.init.cache.refresh_key(localization.full_key)
    visit('/pl/welcome')
    assert page.has_content?(text)
  end

  test "should not fallback if not asked to" do
    Lit.fallback = false
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/en/welcome')
    assert page.has_content?('English translation')
    visit('/pl/welcome')
    assert page.has_content?('Text with translation in english')
  end

  test "should properly fallback" do
    Lit.fallback = true
    Redis.new.flushall
    Lit.init.cache.reset
    I18n.backend.reload!
    visit('/en/welcome')
    assert page.has_content?('English translation')
    visit('/pl/welcome')
    assert page.has_content?('English translation')
  end
end
