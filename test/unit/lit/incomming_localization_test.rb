require 'test_helper'

module Lit
  class IncommingLocalizationTest < ActiveSupport::TestCase
    def setup
      DatabaseCleaner.clean_with :truncation
      stub_request(:get, 'http://testhost.com/lit/api/v1/last_change.json').
        to_return(body: { last_change: 1.hour.ago.to_s(:db) }.to_json)
      @source = Lit::Source.new
      @source.url = 'http://testhost.com/lit'
      @source.api_key = 'test'
      @source.identifier = 'test'
      @source.save!
    end

    test 'on accept deletes itself and creates all missing records' do
      assert_equal 0, Locale.count
      assert_equal 0, Localization.count
      assert_equal 0, LocalizationKey.count
      il = IncommingLocalization.new
      il.locale_str = 'de'
      il.localization_key_str = 'scope.test'
      il.translated_value = 'test'
      il.source = @source
      il.save!
      assert_equal 0, Locale.count
      assert_equal 0, Localization.count
      assert_equal 0, LocalizationKey.count
      il.accept
      assert_equal 1, Locale.count
      assert_equal 1, Localization.count
      assert_equal 1, LocalizationKey.count
      assert_equal true, Localization.first.is_changed?
    end
  end
end
