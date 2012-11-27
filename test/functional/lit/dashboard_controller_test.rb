require 'test_helper'

module Lit
  class DashboardControllerTest < ActionController::TestCase
    test "should get index" do
      get :index, :use_route => :lit
      assert_response :success
    end

  end
end
