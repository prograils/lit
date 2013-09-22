require 'test_helper'

module Lit
  class LocalizationTest < ActiveSupport::TestCase
    test "does not create version upon creation" do
      I18n.locale = :en
      Redis.new.flushall
      assert_no_difference 'Lit::LocalizationVersion.count' do
        Lit.init.cache.reset
        assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
      end
    end

    test "does create new version upon update via model" do
      I18n.locale = :en
      Redis.new.flushall
      assert_difference 'Lit::LocalizationVersion.count' do
        Lit.init.cache.reset
        assert_equal 'English translation', I18n.t('scope.text_with_translation_in_english')
        lang = Lit::Locale.find_by_locale("en")
        lk = Lit::LocalizationKey.find_by_localization_key('scope.text_with_translation_in_english')
        l = Lit::Localization.where('localization_key_id=?',lk).where('locale_id=?',lang).first
        assert_not_nil l
        l.translated_value = "test"
        l.save!
      end
      Lit.init.cache.reset
      assert_equal 'test', I18n.t('scope.text_with_translation_in_english')
    end
  end
end
