require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  def setup
    Lit::Localization.delete_all
    Lit::LocalizationKey.delete_all
    Lit::LocalizationVersion.delete_all
    Lit.loader = nil
    Lit.init
  end

  test 'should properly show index' do
    # $redis.flushall
    if new_controller_test_format?
      get :index, params: { locale: :en }
    else
      get :index, locale: :en
    end
    assert_response :success
    assert I18n.locale == :en
  end

  test 'should properly load value from yaml' do
    if new_controller_test_format?
      get :index, params: { locale: :en }
    else
      get :index, locale: :en
    end
    assert Lit::LocalizationKey.where(localization_key: 'date.abbr_day_names').exists?
    assert_equal I18n.t('date.abbr_day_names'), %w( Sun Mon Tue Wed Thu Fri Sat )
  end

  test 'should properly store key with default value' do
    if new_controller_test_format?
      get :index, params: { locale: :en }
    else
      get :index, locale: :en
    end
    localization_key = Lit::LocalizationKey.where(localization_key: 'scope.text_with_default').first
    assert localization_key.present?
    locale = Lit::Locale.find_by(locale: :en)
    localization = localization_key.localizations.find_by(locale_id: locale.id)
    assert_equal localization.translation, 'Default content'
    assert_equal localization.to_s, 'Default content'
    assert_equal localization.default_value, 'Default content'
  end
end
