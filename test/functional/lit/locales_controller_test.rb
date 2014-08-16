require 'test_helper'

module Lit
  class LocalesControllerTest < ActionController::TestCase
    setup do
      Lit.authentication_function = nil
      @locale = Locale.first_or_create(locale: 'en')
    end

    test 'should get index' do
      get :index, use_route: :lit
      assert_response :success
      assert_not_nil assigns(:locales)
    end

    test 'should hide locale' do
      put :hide, id: @locale, locale: {}, use_route: :lit, format: :js
      assert assigns(:locale).is_hidden?
    end

    test 'should destroy locale' do
      assert_difference('Locale.count', -1) do
        delete :destroy, id: @locale, use_route: :lit
      end
    end
  end
end
