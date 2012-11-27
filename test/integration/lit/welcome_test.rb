# encoding: utf-8
require 'test_helper'

class WelcomeTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "should properly display 'Hello world' in english" do
    Lit.init.cache.reset
    visit('/en/welcome')
    assert page.has_content?('Hello World')
  end

  test "should properly display 'Hello world' in polish" do
    Lit.init.cache.reset
    visit('/pl/welcome')
    assert page.has_content?('Witaj świecie')
  end

  test "should properly display 'Hello world' in polish after change" do
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
end
