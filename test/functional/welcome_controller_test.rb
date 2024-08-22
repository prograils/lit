require "test_helper"

class WelcomeControllerTest < ActionController::TestCase
  def setup
    Lit::Localization.delete_all
    Lit::LocalizationKey.delete_all
    Lit::LocalizationVersion.delete_all
    Lit.loader = nil
    Lit.ignore_yaml_on_startup = false
    Lit.init
  end

  def teardown
    Lit.ignore_yaml_on_startup = nil
  end

  test "should properly show index" do
    # $redis.flushall
    get :index, params: {locale: :en}
    assert_response :success
    assert I18n.locale == :en
  end

  test "should properly load value from yaml" do
    get :index, params: {locale: :en}
    assert Lit::LocalizationKey.where(localization_key: "date.abbr_day_names").exists?
    assert_equal I18n.t("date.abbr_day_names"), %w[Sun Mon Tue Wed Thu Fri Sat]
  end

  test "should properly store key with default value" do
    get :index, params: {locale: :en}
    localization_key = Lit::LocalizationKey.where(localization_key: "scope.text_with_default").first
    assert localization_key.present?
    locale = Lit::Locale.find_by(locale: :en)
    localization = localization_key.localizations.find_by(locale_id: locale.id)

    assert_equal "Default content", localization.translation
    assert_equal "Default content", localization.to_s
    assert_equal "Default content", localization.default_value
  end
end
