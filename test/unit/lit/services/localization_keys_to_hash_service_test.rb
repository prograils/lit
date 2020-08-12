require 'test_helper'

module Lit
  class LocalizationKeysToHashServiceTest < ActiveSupport::TestCase
    test 'accepts flat hash of keys/translations and forms a tree' do
      flat_hash = {
        'en.js.layouts.back' => 'Back',
        'en.js.layouts.home' => 'Home',
        'en.js.common.new' => 'New'
      }
      result = LocalizationKeysToHashService.call(flat_hash)
      assert_equal result.keys.length, 1
      inner = result['en']['js']
      assert inner.key?('layouts')
      assert inner.key?('common')
      assert_equal inner['layouts']['home'], 'Home'
      assert_equal inner['common']['new'], 'New'
    end
  end
end
