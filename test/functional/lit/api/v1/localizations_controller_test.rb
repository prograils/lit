require 'test_helper'

module Lit
  class Api::V1::LocalizationsControllerTest < ActionController::TestCase
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
      Lit::Localization.update_all ['updated_at=?', 2.hours.ago]
      l = Lit::Localization.last
      l.translated_value = "test"
      l.save
      get :index, :format=>:json, :after=>2.seconds.ago.to_s(:db)
      assert_response :success
      assert_equal 1, assigns(:localizations).count
      assert response.body =~ /#{l.value}/
    end
    test "should return last update date" do
      I18n.l(Time.now)
      Lit::Localization.update_all ['updated_at=?', 2.hours.ago]
      l = Lit::Localization.last
      l.translated_value = "test"
      l.save
      get :last_change, :format=>:json
      assert_response :success
      assert_equal l, assigns(:localization)
      assert response.body =~ /#{l.updated_at.to_s(:db)}/

    end
  end
end
