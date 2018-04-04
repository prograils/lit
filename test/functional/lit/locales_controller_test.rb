require 'test_helper'

module Lit
  class LocalesControllerTest < ActionController::TestCase
    setup do
      @routes = Lit::Engine.routes

      Lit.authentication_function = nil
      @locale = Locale.first_or_create(locale: 'en')
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:locales)
    end

    test 'should hide locale' do
      if new_controller_test_format?
        put :hide, params: { id: @locale, locale: {}, format: :js }
      else
        put :hide, id: @locale, locale: {}, format: :js
      end
      assert assigns(:locale).is_hidden?
    end

    test 'should destroy locale' do
      assert_difference('Locale.count', -1) do
        if new_controller_test_format?
          delete :destroy, params: { id: @locale }
        else
          delete :destroy, id: @locale
        end
      end
    end
  end
end
