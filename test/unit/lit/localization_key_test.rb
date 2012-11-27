require 'test_helper'

module Lit
  class LocalizationKeyTest < ActiveSupport::TestCase
    fixtures :lit_localization_keys
    set_fixture_class :lit_localization_keys => Lit::LocalizationKey
    test "uniqueness checking" do
      l = lit_localization_keys(:hello_world)
      lk = Lit::LocalizationKey.new({:localization_key=>l.localization_key})
      assert (not lk.valid?)
    end
  end
end
