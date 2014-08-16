require 'test_helper'

module Lit
  class LocalizationKeyTest < ActiveSupport::TestCase
    fixtures 'lit/localization_keys'

    test 'uniqueness checking' do
      l = lit_localization_keys(:hello_world)
      lk = Lit::LocalizationKey.new(localization_key: l.localization_key)
      assert (!lk.valid?)
    end
  end
end
