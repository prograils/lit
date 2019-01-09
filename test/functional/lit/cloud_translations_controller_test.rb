# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Lit
  class CloudTranslationsControllerTest < ActionController::TestCase
    fixtures 'lit/localizations', 'lit/locales', 'lit/localization_keys'

    setup do
      @routes = Lit::Engine.routes
      Lit.stubs(:authentication_function).returns(nil)
      Lit::CloudTranslation.stubs(:provider).returns(
        Class.new do
          def self.translate(text:, from: nil, to:, **opts)
            "[#{from}->#{to}] #{text.reverse}"
          end
        end
      )
      @array_localization = Lit::Localization.all.find { |l| l.default_value.is_a?(Array) }
      @string_localization = Lit::Localization.all.find { |l| !l.default_value.is_a?(Array) }
      @array_localization.update!(locale: Locale.find_by(locale: 'pl'))
      @string_localization.update!(locale: Locale.find_by(locale: 'pl'))

      en_locale = Locale.find_by(locale: 'en')

      @en_string_localization = @string_localization.localization_key.localizations.create!(
        locale: en_locale,
        default_value: 'qwer',
        translated_value: 'asdf',
        is_changed: true
      )
      @en_array_localization = @array_localization.localization_key.localizations.create!(
        locale: en_locale,
        default_value: ['this', 'is', 'awesome'],
        translated_value: ['but', 'this', 'too'],
        is_changed: true
      )
    end

    test 'translating an array localization from known language' do
      call_action :get, :show,
                  params: { localization_id: @array_localization.id, from: 'en', format: 'js' }
      assert assigns[:localization] == @en_array_localization
      assert assigns[:target_localization] == @array_localization
      assert assigns[:translated_text] == "[en->pl] #{@en_array_localization.translated_value.reverse}"
    end

    test 'translating a string localization from known language' do
      call_action :get, :show,
                  params: { localization_id: @string_localization.id, from: 'en', format: 'js' }
      assert assigns[:localization] == @en_string_localization
      assert assigns[:target_localization] == @string_localization
      assert assigns[:translated_text] == "[en->pl] #{@en_string_localization.translated_value.reverse}"
    end

    test 'translating a string localization from itself as auto' do
      call_action :get, :show,
                  params: { localization_id: @string_localization.id, from: 'auto', format: 'js' }
      assert assigns[:target_localization] == @string_localization
      assert assigns[:translated_text] == "[->pl] #{@string_localization.translated_value.reverse}"
    end

    test 'translation error is gracefully intercepted' do
      Lit::CloudTranslation
        .provider
        .stubs(:translate)
        .raises(Lit::CloudTranslation::TranslationError, 'Something went wrong')

      call_action :get, :show,
                  params: { localization_id: @string_localization.id, from: 'auto', format: 'js' }

      assert assigns[:error_message].match(/Something went wrong/)
      pseudo_browser = ExecJS.compile(
        <<-JS
        var alert =
          function(text) { return "Displaying alert: " + "#{assigns[:error_message]}" }
        JS
      )
      assert pseudo_browser.eval(response.body) == 'Displaying alert: ' \
                                                   "#{assigns[:error_message]}"
    end
  end
end
