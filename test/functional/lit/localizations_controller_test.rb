require 'test_helper'

module Lit
  class LocalizationsControllerTest < ActionController::TestCase
    fixtures :all

    setup do
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      @localization = lit_localizations(:array)
    end

    test "should get edit" do
      get :edit, :localization_key_id => @localization.localization_key.id, :id => @localization.id, :format => :js
      assert_response :success
      assert_not_nil assigns(:localization)
    end

    test "should get previous_versions" do
      get :previous_versions, :localization_key_id => @localization.localization_key.id, :id => @localization.id,
          :format => :js
      assert_response :success
      assert_not_nil assigns(:localization)
      assert_not_nil assigns(:versions)
    end

    test "should update localization when translated_value is a string" do
      @localization = lit_localizations(:string)
      put :update, :localization_key_id => @localization.localization_key.id, :id => @localization.id,
          :localization => { :translated_value => "new-value", :locale_id => @localization.locale_id }, :format => :js
      assert_response :success
      @localization.reload
      assert_equal "new-value", @localization.translated_value
    end

    test "should update localization when translated_value is a array" do
      @localization = lit_localizations(:array)
      put :update, :localization_key_id => @localization.localization_key.id, :id => @localization.id,
          :localization => { :translated_value => ["three", "two", "one"], :locale_id => @localization.locale_id },
          :format => :js
      assert_response :success
      @localization.reload
      assert_equal ["three", "two", "one"], @localization.translated_value
    end

  end
end
