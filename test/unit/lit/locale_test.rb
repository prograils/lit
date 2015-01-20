require 'test_helper'

module Lit
  class LocaleTest < ActiveSupport::TestCase
    fixtures 'lit/locales'

    test 'uniqueness checking' do
      l = lit_locales(:pl)
      locale = Lit::Locale.new(locale: l.locale)
      assert (!locale.valid?)
    end

    test 'just locale scope returns just the specified locale' do
      locale_pl = lit_locales(:pl)
      locale_en = lit_locales(:en)
      assert_equal([locale_pl], Lit::Locale.just_locale(:pl))
    end
  end
end
