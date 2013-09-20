require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  test "should properly show index" do
    #$redis.flushall
    get :index, :locale=>:en
    assert_response :success
    assert I18n.locale == :en
    assert Lit::LocalizationKey.where(:localization_key=>'date.abbr_day_names').exists?
    assert_equal I18n.t('date.abbr_day_names'), %w( Sun Mon Tue Wed Thu Fri Sat )
  end
end
