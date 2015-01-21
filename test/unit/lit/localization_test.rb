require 'test_helper'

module Lit
  class LocalizationTest < ActiveSupport::TestCase
    fixtures 'lit/localization_keys'
    fixtures 'lit/locales'

    def setup
      l = lit_localization_keys(:hello_world)
      locale_pl = lit_locales(:pl)
      locale_en = lit_locales(:en)
      @lc_pl = Lit::Localization.new()
      @lc_pl.locale = locale_pl
      @lc_pl.default_value = nil
      @lc_pl.localization_key = l
      @lc_pl.save()

      @lc_en = Lit::Localization.new()
      @lc_en.locale = locale_en
      @lc_en.localization_key = l
      @lc_en.default_value = "Some text"
      @lc_en.save()

      @array = lit_localization_keys(:array)
      @lc_array_pl = Lit::Localization.new()
      @lc_array_pl.locale = locale_pl
      @lc_array_pl.localization_key = @array
      @lc_array_pl.save()
    end

    test 'does not create version upon creation' do
      I18n.locale = :en
      assert_no_difference 'Lit::LocalizationVersion.count' do
        Lit.init.cache.reset
        assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
      end
    end

    test 'does create new version upon update via model' do
      I18n.locale = :en
      assert_difference 'Lit::LocalizationVersion.count' do
        Lit.init.cache.reset
        assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
        lang = Lit::Locale.find_by_locale('en')
        lk = Lit::LocalizationKey.find_by_localization_key('scope.text_with_translation_in_english')
        l = Lit::Localization.where('localization_key_id=?', lk).where('locale_id=?', lang).first
        assert_not_nil l
        l.update_attribute :is_changed, false
        l.reload
        l.translated_value = 'test'
        l.save!
        l.reload
        assert_equal true, l.is_changed?
      end
      Lit.init.cache.reset
      assert_equal 'test', I18n.t('scope.text_with_translation_in_english')
    end

    test 'without_value returns only localizations without a value' do
      assert_equal([@lc_pl], Lit::Localization.without_value)
    end

    test 'locale scope returns only localizaions of a specific locale' do
      assert_equal([@lc_en], Lit::Localization.for_locale(:en))
    end

    test 'within scope filters by localization keys' do
      scope = Lit::LocalizationKey.where(id: @array.id)
      assert_equal([@lc_array_pl], Lit::Localization.within(scope))
      scope = Lit::LocalizationKey.all
      assert_equal(3, Lit::Localization.within(scope).count)
    end
  end
end
