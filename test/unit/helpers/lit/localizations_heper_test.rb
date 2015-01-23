require 'test_helper'

module Lit
  class LocalizationsHelperTest < ActionView::TestCase
    fixtures 'lit/localization_keys'
    fixtures 'lit/locales'
    include LocalizationsHelper

    test "locales returns available_locale when no current_locale was given" do
      @current_locale = nil
      assert_equal(I18n.available_locales, locales)
    end

    test "locales returns only current_locale when it was given" do
      @current_locale = :en
      assert_equal([:en], locales)
    end

    test "default_localization returns null when localizations doesn't exist" do
      localization_key = lit_localization_keys(:hello_world)
      assert_equal('null', default_localization(localization_key))
    end

    test "default_localization returns localization when it exists" do
      localization_key = lit_localization_keys(:hello_world)
      locale = lit_locales(:en)
      lc = Lit::Localization.new()
      lc.localization_key = localization_key
      lc.default_value = "Nothing"
      lc.locale = locale
      lc.save
      assert_equal("Nothing", default_localization(localization_key))
    end
  end
end
