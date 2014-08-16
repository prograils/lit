require 'test_helper'

module Lit
  class DashboardControllerTest < ActionController::TestCase
    test 'should require auth / should redirect' do
      Lit.authentication_function = :authenticate_admin!
      get :index, use_route: :lit
      assert_response 302
    end

    test 'should show index if none auth function is defined' do
      Lit.authentication_function = nil
      get :index, use_route: :list
      assert_response :success
    end
  end
end
