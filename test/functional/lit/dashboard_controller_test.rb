require 'test_helper'

module Lit
  class DashboardControllerTest < ActionController::TestCase
    setup do
      @routes = Lit::Engine.routes
    end

    test 'should require auth / should redirect' do
      Lit.authentication_function = :authenticate_admin!
      get :index
      assert_response 302
    end

    test 'should show index if none auth function is defined' do
      Lit.authentication_function = nil
      get :index
      assert_response :success
    end
  end
end
