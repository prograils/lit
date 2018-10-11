require 'test_helper'

module Lit
  class LocalizationKeyTest < ActiveSupport::TestCase
    fixtures 'lit/localization_keys'

    setup do
      @lk = lit_localization_keys(:hello_world)
      @locale_en = Lit::Locale.create(locale: :en)
      @locale_pl = Lit::Locale.create(locale: :pl)
      @loc1 = @lk.localizations.create translated_value: 'test',
                                       locale: @locale_en
      @loc2 = @lk.localizations.create translated_value: 'test',
                                       locale: @locale_pl
    end

    teardown do
      Lit.init.cache.reset
    end

    test 'uniqueness checking' do
      lk = Lit::LocalizationKey.new(localization_key: @lk.localization_key)
      assert_not lk.valid?
    end

    test 'when all localizations are changed, localization key should mark as completed' do
      assert_not @lk.is_completed
      @loc1.update is_changed: true
      @loc2.update is_changed: true
      assert @lk.reload.is_completed
    end

    test '#change_all_completed should mark everything as changed/completed' do
      assert_not @lk.is_completed
      assert_not @loc1.is_changed
      assert_not @loc2.is_changed
      @lk.change_all_completed
      assert @lk.reload.is_completed
      assert @loc1.reload.is_changed
      assert @loc2.reload.is_changed
    end
  end
end
