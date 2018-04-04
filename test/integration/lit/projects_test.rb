# encoding: utf-8
require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  setup do
    @old = Lit.humanize_key
    Lit.humanize_key = true
  end
  teardown do
    Lit.humanize_key = @old
  end

  test 'should display translated project name' do
    visit('/en/projects/new')
    locale = Lit::Locale.where('locale=?', 'en').first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'helpers.label.project.name'
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal 'Name', localization.to_s
    assert_equal 'Name', localization.default_value
  end
end
