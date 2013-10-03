require 'test_helper'

module Lit
  class Api::V1::LocalizationKeysControllerTest < ActionController::TestCase
    def setup
      Lit.api_enabled = true
      Lit.api_key = "test"
      Lit::Engine.routes.clear!
      Dummy::Application.reload_routes!
      @routes = Lit::Engine.routes
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("test")
      I18n.t('scope.text_with_translation_in_english')
    end
    test "should get index" do
      get :index, :format=>:json
      assert_response :success
    end
    test "should only changed records" do
      I18n.l(Time.now)
      Lit::LocalizationKey.update_all ['updated_at=?', 2.hours.ago]
      l = Lit::LocalizationKey.last
      l.touch
      get :index, :format=>:json, :after=>I18n.l(2.seconds.ago)
      assert_response :success
      assert_equal 1, assigns(:localization_keys).count
      assert response.body =~ /#{l.localization_key}/
    end
  end
end

