require 'test_helper'

module Lit
  class LocaleTest < ActiveSupport::TestCase
    fixtures 'lit/locales'

    test "uniqueness checking" do
      l = lit_locales(:pl)
      locale = Lit::Locale.new({:locale=>l.locale})
      assert (not locale.valid?)
    end
  end
end
