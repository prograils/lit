# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Lit
  class CloudTranslationsControllerTest < ActionController::TestCase
    fixtures 'lit/localizations', 'lit/locales', 'lit/localization_keys'

    setup do
      @routes = Lit::Engine.routes
      Lit.stubs(:authentication_function).returns(nil)
      Lit::Cloud.stubs(:provider).returns(
        Class.new do
          def self.translate(text:, from: nil, to:, **opts)
            "[#{from}->#{to}] #{text.reverse}"
          end
        end
      )
      @array_localization = Lit::Localization.all.find { |l| l.default_value.is_a?(Array) }
      @string_localization = Lit::Localization.all.find { |l| l.default_value.is_a?(Array) }
      @array_localization.update!(locale: Locale.find_by(locale: 'pl'))
      @string_localization.update!(locale: Locale.find_by(locale: 'pl'))
    end

    test 'translating an array localization from unknown language' do
      call_action :get, :show,
                  params: { localization_id: @array_localization.id, from: 'auto', format: 'js' }
      assert assigns[:localization] == @array_localization
      assert assigns[:translated_text] == "[->pl] #{@array_localization.default_value.reverse}"
    end

    test 'translating an array localization from known language' do
      call_action :get, :show,
                  params: { localization_id: @array_localization.id, from: 'en', format: 'js' }
      assert assigns[:localization] == @array_localization
      assert assigns[:translated_text] == "[en->pl] #{@array_localization.default_value.reverse}"
    end

    test 'translating a string localization from unknown language' do
      call_action :get, :show,
                  params: { localization_id: @string_localization.id, from: 'auto', format: 'js' }
      assert assigns[:localization] == @string_localization
      assert assigns[:translated_text] == "[->pl] #{@string_localization.default_value.reverse}"
    end

        test 'translating a string localization from known language' do
      call_action :get, :show,
                  params: { localization_id: @string_localization.id, from: 'en', format: 'js' }
      assert assigns[:localization] == @string_localization
      assert assigns[:translated_text] == "[en->pl] #{@string_localization.default_value.reverse}"
    end
  end
end
