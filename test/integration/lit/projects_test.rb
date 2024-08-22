require "test_helper"

class ProjectsTest < ActionDispatch::IntegrationTest
  setup do
    @old = Lit.store_humanized_key
  end
  teardown do
    Lit.store_humanized_key = @old
  end

  test "should display translated project name" do
    Lit.store_humanized_key = true
    visit("/en/projects/new")
    locale = Lit::Locale.where("locale=?", "en").first
    localization_key = Lit::LocalizationKey.find_by_localization_key! "helpers.label.project.name"
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal "Name", localization.to_s
    assert_equal "Name", localization.default_value
  end

  test "should have error messages" do
    post "/en/projects", params: {project: {name: ""}}
    locale = Lit::Locale.where("locale=?", "en").first
    localization_key = Lit::LocalizationKey.find_by_localization_key! "activerecord.errors.models.project.attributes.name.blank"
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_nil localization.to_s
    assert_nil localization.default_value
  end

  test "should have error message humanized" do
    Lit.store_humanized_key = true
    post "/en/projects", params: {project: {name: ""}}
    locale = Lit::Locale.where("locale=?", "en").first
    localization_key = Lit::LocalizationKey.find_by_localization_key! "activerecord.errors.models.project.attributes.name.blank"
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal "Blank", localization.to_s
    assert_equal "Blank", localization.default_value
  end
end
