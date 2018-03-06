require 'test_helper'

class RawImportTaskTest < ActiveSupport::TestCase
  def setup
    path = Lit::Engine.root.join('test', 'fixtures', 'lit', 'files', 'import.yml.raw')
    @locales = Rails.root.join('config', 'locales', 'import.yml')
    FileUtils.cp path, @locales
    Rake::Task.clear
    Lit::Engine.load_tasks
    Rake::Task.define_task(:environment)
    @old_files = ENV['FILES']
    @old_locale = ENV['LOCALE']
    @old_skip_nil = ENV['SKIP_NIL']
    ENV['FILES'] = 'import.yml'
    ENV['LOCALE'] = 'en'
  end

  def teardown
    ENV['FILES'] = @old_files
    ENV['LOCALE'] = @old_locale
    ENV['SKIP_NIL'] = @old_skip_nil
    FileUtils.rm @locales
  end

  test 'imports locale from selected file and skips nil values' do
    ENV['SKIP_NIL'] = 'true'
    assert Lit::LocalizationKey.where(localization_key: 'hello.world').empty?
    assert Lit::LocalizationKey.where(localization_key: 'hello.nothing').empty?
    assert Lit::LocalizationKey.where(localization_key: 'hello.not_nil').empty?
    Rake::Task['lit:raw_import'].invoke
    assert Lit::LocalizationKey.where(localization_key: 'hello.world').present?
    assert Lit::LocalizationKey.where(localization_key: 'hello.nothing').empty?
    assert Lit::LocalizationKey.where(localization_key: 'hello.not_nil').present?
  end

  test 'imports locale from selected file and imports nil values' do
    ENV['SKIP_NIL'] = 'false'
    assert Lit::LocalizationKey.where(localization_key: 'hello.world').empty?
    assert Lit::LocalizationKey.where(localization_key: 'hello.nothing').empty?
    assert Lit::LocalizationKey.where(localization_key: 'hello.not_nil').empty?
    Rake::Task['lit:raw_import'].invoke
    assert Lit::LocalizationKey.where(localization_key: 'hello.world').present?
    assert Lit::LocalizationKey.where(localization_key: 'hello.nothing').present?
    assert Lit::LocalizationKey.where(localization_key: 'hello.not_nil').present?
  end
end
