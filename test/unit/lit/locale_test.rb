require 'test_helper'

module Lit
  class LocaleTest < ActiveSupport::TestCase
    fixtures :lit_locales
    set_fixture_class :lit_locales => Lit::Locale
    test "uniqueness checking" do
      l = lit_locales(:pl)
      locale = Lit::Locale.new({:locale=>l.locale})
      assert (not locale.valid?)
    end
  end
end
