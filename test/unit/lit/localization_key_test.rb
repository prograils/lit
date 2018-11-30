require 'test_helper'

module Lit
  class LocalizationKeyTest < ActiveSupport::TestCase
    fixtures 'lit/localization_keys'

    setup do
      @lk = Lit::LocalizationKey.create(localization_key: 'testing')
      @locale_en = Lit::Locale.create(locale: :en)
      @locale_pl = Lit::Locale.create(locale: :pl)
      @loc1 = @lk.localizations.create translated_value: 'test',
                                       locale: @locale_en
      @loc2 = @lk.localizations.create translated_value: 'test',
                                       locale: @locale_pl
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

    test '#soft_destroy should mark translation key as deleted and translations as completed' do
      assert_not @lk.is_completed
      assert_not @loc1.is_changed
      assert_not @loc2.is_changed
      @lk.soft_destroy
      assert @lk.reload.is_deleted
      assert @lk.localizations.all?(&:is_changed)
    end

    test '#soft_destroy should delete translation key from memoized objects' do
      lk_obj_cache = Lit.init.cache.instance_variable_get(:@localization_key_object_cache)
      Lit.init.cache.refresh_key("en.#{@lk.localization_key}")
      assert lk_obj_cache[@lk.localization_key] == @lk
      @lk.soft_destroy
      refute lk_obj_cache.key?(@lk.localization_key)
    end

    test '#restore should restore translation key' do
      @lk.change_all_completed
      @lk.update is_deleted: true, is_visited_again: true
      assert @lk.is_deleted
      assert @lk.is_completed
      assert @lk.is_visited_again
      @lk.restore
      assert_not @lk.is_deleted
      assert_not @lk.is_completed
      assert_not @lk.is_visited_again
    end
  end
end
