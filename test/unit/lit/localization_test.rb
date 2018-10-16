require 'test_helper'

module Lit
  class LocalizationTest < ActiveSupport::TestCase
    def setup
      Lit::Localization.delete_all
      Lit::LocalizationKey.delete_all
      Lit::LocalizationVersion.delete_all
      Lit.loader = nil
      Lit.init
      I18n.locale = :en
    end

    test 'does not create version upon creation' do
      assert_no_difference 'Lit::LocalizationVersion.count' do
        Lit.init.cache.reset
        assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
      end
    end

    test 'does create new version upon update via model' do
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
        l.update_attribute :is_changed, true
        l.reload
        assert_equal true, l.is_changed?
      end
      Lit.init.cache.reset
      assert_equal 'test', I18n.t('scope.text_with_translation_in_english')
    end

    test 'does not set is_changed to true upon update via model' do
      assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
      l = Lit::Localization.first
      assert_equal false, l.is_changed?
      l.update_attributes(translated_value: 'Test')
      assert_equal false, l.is_changed?
    end
  end

  test 'after update cache should be modified' do
    locale = Lit::Locale.find_by_locale('en')
    lk = Lit::LocalizationKey.first
    loc = lk.localizations.create locale: locale, is_changed: false
    assert_not Lit.init.cache[loc.full_key]
    loc.update translated_value: 'test'
    assert_equal Lit.init.cache[loc.full_key], 'test'
  end
end
