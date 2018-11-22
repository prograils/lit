# encoding: utf-8
require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  setup do
    @old = Lit.humanize_key
  end
  teardown do
    Lit.humanize_key = @old
  end

  test 'should display translated project name' do
    Lit.humanize_key = true
    visit('/en/projects/new')
    locale = Lit::Locale.where('locale=?', 'en').first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'helpers.label.project.name'
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal 'Name', localization.to_s
    assert_equal 'Name', localization.default_value
  end

  test 'should have error messages' do
    if ::Rails::VERSION::MAJOR < 5
      post '/en/projects', project: { name: '' }
    else
      post '/en/projects', params: { project: { name: '' } }
    end
    locale = Lit::Locale.where('locale=?', 'en').first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'activerecord.errors.models.project.attributes.name.blank'
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_nil localization.to_s
    assert_nil localization.default_value
  end

  test 'should have error message humanized' do
    Lit.humanize_key = true
    if ::Rails::VERSION::MAJOR < 5
      post '/en/projects', project: { name: '' }
    else
      post '/en/projects', params: { project: { name: '' } }
    end
    locale = Lit::Locale.where('locale=?', 'en').first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'activerecord.errors.models.project.attributes.name.blank'
    localization = localization_key.localizations.where(locale_id: locale.id).first
    assert_equal 'Blank', localization.to_s
    assert_equal 'Blank', localization.default_value
  end
end
