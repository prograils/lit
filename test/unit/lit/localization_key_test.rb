require 'test_helper'

module Lit
  class LocalizationKeyTest < ActiveSupport::TestCase
    fixtures 'lit/localization_keys'
    fixtures 'lit/locales'

    test 'uniqueness checking' do
      l = lit_localization_keys(:hello_world)
      lk = Lit::LocalizationKey.new(localization_key: l.localization_key)
      assert (!lk.valid?)
    end

    test 'nulls_for scope' do
      l = lit_localization_keys(:hello_world)
      locale_pl = lit_locales(:pl)
      locale_en = lit_locales(:en)
      localization = Lit::Localization.new()
      localization.locale = locale_pl
      localization.localization_key = l
      localization.save()

      localization = Lit::Localization.new()
      localization.locale = locale_en
      localization.localization_key = l
      localization.default_value = "Some text"
      localization.save()

      assert_equal([l], Lit::LocalizationKey.nulls_for(:pl))
      assert_equal([], Lit::LocalizationKey.nulls_for(:en))
    end
  end
end
