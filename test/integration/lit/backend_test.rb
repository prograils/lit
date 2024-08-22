require "test_helper"

class BackendTest < ActionDispatch::IntegrationTest
  def setup
    @old_locale = I18n.locale
    I18n.locale = :pl
  end

  def teardown
    I18n.locale = @old_locale
  end

  test "when generating locale while listing localizations it should copy default_value" do
    Lit.authentication_function = nil
    Lit::Locale.where(locale: "en").first_or_create
    I18n.t("prograils.swag", default: "Prograils codelovers")
    lk = Lit::LocalizationKey.find_by(localization_key: "prograils.swag")
    assert lk.present?
    visit("/lit/localization_keys")
    lk.reload
    assert lk.localizations.map(&:default_value).compact.count == Lit::Locale.all.count
  end
end
