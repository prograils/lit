require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  test "should properly show index" do
    get :index, :locale=>:en
    assert_response :success
    assert I18n.locale == :en
  end
end
