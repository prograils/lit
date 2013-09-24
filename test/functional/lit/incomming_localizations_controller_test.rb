require 'test_helper'

module Lit
  class IncommingLocalizationsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
