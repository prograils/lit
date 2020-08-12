require 'test_helper'

class LitBehaviourTest < ActiveSupport::TestCase
  class Backend < Lit::I18nBackend
  end

  def setup
    Lit::Localization.delete_all
    Lit::LocalizationKey.delete_all
    Lit::LocalizationVersion.delete_all

    @old_load_path = I18n.load_path
    @old_humanize_key = Lit.humanize_key
    @old_backend = I18n.backend
    @old_ignore = Lit.ignore_yaml_on_startup

    I18n.load_path = []
    Lit.humanize_key = false
    I18n.backend = Backend.new(Lit.loader.cache)
    super
  end

  def teardown
    Lit.humanize_key = @old_humanize_key
    I18n.backend = @old_backend
    I18n.load_path = @old_load_path
    Lit.ignore_yaml_on_startup = @old_ignore
    super
  end

  test 'returned strings must not be html_safe if all_translations_are_html_safe is false' do
    with_all_translations_are_html_safe false do
      I18n.backend.store_translations(:en, foo: 'foo')
      assert_equal false, I18n.t('foo').html_safe?
    end
  end

  test 'returned strings must be html_safe if all_translations_are_html_safe is true' do
    with_all_translations_are_html_safe true do
      I18n.backend.store_translations(:en, foo: 'foo')
      assert I18n.t('foo').html_safe?
    end
  end

  test 'should not save in other languages than I18n.available_locales' do
    ::Rails.configuration.i18n.stubs(:available_locales).returns([:fr])
    I18n.backend.expects(:store_item).times(0)
    I18n.backend.store_translations(:dk, foo: 'foo')
  end

  test 'should save in other languages if I18n.available_locales is empty' do
    I18n.backend.expects(:store_item).times(1)
    I18n.backend.store_translations(:dk, foo: 'foo')
  end

  test 'should override default gems translations' do
    load_paths = @old_load_path.
      select { |p| p.include?('lib/active_support/locale/en.yml') }
    load_paths <<
      File.expand_path('../../dummy/config/locales/active_support_extensions.yml', __FILE__)

    I18n.load_path = load_paths

    assert_equal '%B %d, %Y extended',
                 I18n.backend.translate(:en, :"date.formats.long")

    # check once again if I18n.backend.translate returns expected value. There
    # where a bug with cache initialized to late and first call to translate
    # returned other results then second call.
    assert_equal '%B %d, %Y extended',
                 I18n.backend.translate(:en, :"date.formats.long")
  end

  test 'translating the same not existing key twice should not set Lit::Localizaiton#is_changed to true' do
    key = 'not_existing_translation'

    assert_nil find_localization_for(key, 'en')

    assert_equal "translation missing: en.#{key}", I18n.t(key)
    assert_equal false, find_localization_for(key, 'en').is_changed?

    assert_equal "translation missing: en.#{key}", I18n.t(key)
    assert_equal false, find_localization_for(key, 'en').is_changed?
  end

  test 'translations with scope, default and interpolation should use interpolation every time' do
    I18n.backend.store_translations(:en, :'scope.foo' => 'foo %{bar}')

    assert_equal 'foo bar',     I18n.t(:"scope.blank", default: :'scope.foo', bar: 'bar')
    assert_equal 'foo bar bis', I18n.t(:"scope.blank", default: :'scope.foo', bar: 'bar bis')

    I18n.backend.store_translations(:en, :'next_scope.foo' => 'foo %{bar}')
    assert_equal 'foo bar',     I18n.t(:blank, scope: :next_scope, default: :foo, bar: 'bar')
    assert_equal 'foo bar bis', I18n.t(:blank, scope: :next_scope, default: :foo, bar: 'bar bis')
  end

  test 'lit should respect :scope when setting default_value from defaults' do
    I18n.backend.store_translations(:en, :'scope.foo' => 'translated foo')

    assert_equal 'translated foo', I18n.t(:not_existing, scope: ['scope'], default: [:foo])
    assert_equal 'translated foo', find_localization_for('scope.not_existing', 'en').default_value
  end

  test 'it stores translations upon first invokation' do
    key = 'test.of.storage'
    I18n.t(key)
    assert Lit::LocalizationKey.where(localization_key: key).exists?
  end

  test 'it wont store key if prefix is added to ignored' do
    old_loader = Lit.loader
    key = 'test.of.storage'
    existing_key = 'existing.string'
    Lit.ignored_keys = ['test.of']
    Lit.loader = nil
    Lit.init
    I18n.t(key)
    I18n.t(existing_key)
    assert !Lit::LocalizationKey.where(localization_key: key).exists?
    assert Lit::LocalizationKey.where(localization_key: existing_key).exists?
    Lit.loader = old_loader
  end

  test 'it wont store key if ignored_key prefix is a string' do
    old_loader = Lit.loader
    first_key = 'test.of.storage'
    second_key = 'secondary.key.to.test'
    existing_key = 'existing.string'
    Lit.ignored_keys = 'test.of, secondary.key '
    Lit.loader = nil
    Lit.init
    I18n.t(first_key)
    I18n.t(second_key)
    I18n.t(existing_key)
    assert !Lit::LocalizationKey.where(localization_key: first_key).exists?
    assert !Lit::LocalizationKey.where(localization_key: second_key).exists?
    assert Lit::LocalizationKey.where(localization_key: existing_key).exists?
    Lit.loader = old_loader
  end

  test 'it wont overwrite existing UI-changed values with those from yaml' do
    load_sample_yml('en.yml')
    old_loader = Lit.loader
    Lit.loader = nil
    Lit.init

    # Defaults from yml: en.foo: bar, en.nil_thing: [nothing]
    assert_equal 'bar', I18n.t('foo')
    assert_equal 'no longer nil', I18n.t('nil_thing', default: 'no longer nil')

    foo_loc = Lit::LocalizationKey.find_by_localization_key('foo').localizations.first
    nil_loc = Lit::LocalizationKey.find_by_localization_key('nil_thing').localizations.first

    # Check if default values have been loaded into DB
    assert_equal 'bar', foo_loc.default_value
    assert_equal 'no longer nil', nil_loc.default_value

    # Translate as if it was done in UI (is_changed set to true)
    foo_loc.update(translated_value: 'barbar', is_changed: true)
    nil_loc.update(translated_value: 'new one', is_changed: true)
    [foo_loc, nil_loc].each do |loc|
      Lit.init.cache.update_cache loc.full_key, loc.translation
    end

    # Translations should be changed as intended
    assert_equal 'barbar', I18n.t('foo')
    assert_equal 'new one', I18n.t('nil_thing')

    # Reload Lit, UI-changed translations should be intact
    Lit.loader = nil
    Lit.init
    assert_equal 'barbar', I18n.t('foo')
    assert_equal 'new one', I18n.t('nil_thing')

    Lit.loader = old_loader
  end

  test 'it will overwrite existing values with those from yaml for unchanged localizations' do
    Lit.ignore_yaml_on_startup = false
    load_sample_yml('en.yml')
    old_loader = Lit.loader
    Lit.loader = nil
    Lit.init

    # Defaults from en.yml: en.foo: bar, en.nil_thing: [nothing]
    assert_equal 'bar', I18n.t('foo')
    assert_equal 'no longer nil', I18n.t('nil_thing', default: 'no longer nil')

    foo_loc = Lit::LocalizationKey.find_by_localization_key('foo')
                                  .localizations.first
    nil_loc = Lit::LocalizationKey.find_by_localization_key('nil_thing')
                                  .localizations.first

    # Check if default values have been loaded into DB
    assert_equal 'bar', foo_loc.default_value
    assert_equal 'no longer nil', nil_loc.default_value

    # Defaults from en_changed.yml en.foo: barbar, en.nil_thing: not nil anymore
    # Swap yml file and reload Lit, changes in yml file should be visible
    I18n.load_path = []
    load_sample_yml('en_changed.yml')
    Lit.loader = nil
    Lit.init
    assert_equal 'barbar', I18n.t('foo')
    assert_equal 'not nil anymore', I18n.t('nil_thing')

    Lit.loader = old_loader
  end

  test 'it replaces nil ("translation missing") values with new defaults' do
    assert_nil find_localization_for('foo', :en)
    I18n.t('foo')
    assert_not_nil find_localization_for('foo', :en)
    I18n.t('foo', default: 'bar')
    assert_equal 'bar', I18n.t('foo')
  end

  if Lit.key_value_engine == 'redis'
    test 'it does not overwrite values in DB with nil if default option is removed from I18n.t call after value is deleted from redis' do
      I18n.t('foo', default: 'bar')
      assert_equal 'bar', find_localization_for('foo', :en).value
      $redis.flushdb # rubocop:disable Style/GlobalVars
      I18n.t('foo')
      assert_equal 'bar', find_localization_for('foo', :en).value
    end
  end

  test 'it does not create duplicate db records when a previously deleted key appears again' do
    loc_count = Lit::Localization.count
    I18n.t('foo', default: 'bar')
    assert Lit::Localization.count == loc_count + 1
    Lit::LocalizationKey.find_by(localization_key: 'foo').soft_destroy
    I18n.t('foo', default: 'baz')
    assert Lit::Localization.count == loc_count + 1
  end

  test 'cache tree structure of keys and retrieve it from redis like I18n does' do
    Lit.humanize_key = true
    assert_difference 'Lit::LocalizationKey.count', 2 do
      I18n.t('scopes.hash.sub_one', default: 'Left leaf')
      I18n.t('scopes.hash.sub_two', default: 'Right leaf')
    end
    assert_no_database_queries do
      assert_equal 'Left leaf', I18n.t('scopes.hash.sub_one')
      assert_equal 'Right leaf', I18n.t('scopes.hash.sub_two')
    end
    hash_result = I18n.t('scopes.hash')
    assert hash_result.is_a?(Hash)
    assert hash_result.key?('sub_one')
    assert hash_result.key?('sub_two')
    assert_equal hash_result['sub_one'], 'Left leaf'
  end

  private

  def find_localization_for(key, locale)
    Lit::Localization.
        joins(:localization_key, :locale).
        where(lit_localization_keys: { localization_key: key }).
        where(lit_locales: { locale: locale }).first
  end

  def with_all_translations_are_html_safe(value)
    previous = Lit.all_translations_are_html_safe
    Lit.all_translations_are_html_safe = value
    yield
  ensure
    Lit.all_translations_are_html_safe = previous
  end
end
