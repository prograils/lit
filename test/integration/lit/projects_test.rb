# encoding: utf-8
require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  test 'should display translated project name' do
    visit('/en/projects/new')
    locale = Lit::Locale.where('locale=?', 'en').first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'helpers.label.project.name'
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal 'Name', localization.to_s
    assert_equal 'Name', localization.default_value
  end
end
