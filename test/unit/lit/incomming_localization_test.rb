require "test_helper"

module Lit
  class IncommingLocalizationTest < ActiveSupport::TestCase
    def setup
      DatabaseCleaner.clean_with :truncation
      stub_request(:get, "http://testhost.com/lit/api/v1/last_change.json").to_return(
        body: {last_change: 1.hour.ago.to_fs(:db)}.to_json
      )
      @source = Lit::Source.create url: "http://testhost.com/lit", api_key: "test", identifier: "test"
    end

    test "on accept deletes itself and creates all missing records" do
      assert_equal 0, Locale.count
      assert_equal 0, Localization.count
      assert_equal 0, LocalizationKey.count
      il =
        IncommingLocalization.create locale_str: "de",
          localization_key_str: "scope.test",
          translated_value: "scope.test",
          source: @source
      assert_equal 0, Locale.count
      assert_equal 0, Localization.count
      assert_equal 0, LocalizationKey.count
      il.accept
      assert_equal 1, Locale.count
      assert_equal 1, Localization.count
      assert_equal 1, LocalizationKey.count
      assert_equal true, Localization.first.is_changed?
    end

    test "#duplicated? returns true when localization key is deleted" do
      locale = Locale.create locale: "en"
      l_k = LocalizationKey.create localization_key: "test"
      localization = Localization.create locale:, localization_key: l_k, default_value: "test test"
      il =
        IncommingLocalization.create locale_str: locale.locale,
          localization_key_str: l_k.localization_key,
          translated_value: localization.translated_value,
          localization:,
          source: @source
      assert il.duplicated?("test test")
    end

    test "#duplicated? returns false when incomming localization key is deleted" do
      locale = Locale.create locale: "en"
      l_k = LocalizationKey.create localization_key: "test"
      localization = Localization.create locale:, localization_key: l_k, translated_value: "test test"
      il =
        IncommingLocalization.create locale_str: locale.locale,
          localization_key_str: l_k.localization_key,
          translated_value: localization.translated_value,
          localization:,
          source: @source,
          localization_key_is_deleted: true
      assert_not il.duplicated?("test test")
    end
  end
end
