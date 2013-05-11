# encoding: utf-8
require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest

  test "should display translated project name" do
    Redis.new.flushall
    Lit.init.cache.reset
    visit('/en/projects/new')
    locale = Lit::Locale.first
    localization_key = Lit::LocalizationKey.find_by_localization_key! 'helpers.label.project.name'
    localization = locale.localizations.where(:localization_key_id=>localization_key.id).first
    assert localization.default_value == 'Name'
  end

end
