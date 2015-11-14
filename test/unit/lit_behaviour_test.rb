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

    I18n.load_path = []
    Lit.humanize_key = false
    I18n.backend = Backend.new(Lit.loader.cache)
    super
  end

  def teardown
    Lit.humanize_key = @old_humanize_key
    I18n.backend = @old_backend
    I18n.load_path = @old_load_path
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

  test 'should not save in other languages then I18n.available_locales' do
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

    assert_equal nil, find_localization_for(key, 'en')

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
    key = 'test.of.storge'
    I18n.t(key)
    assert Lit::LocalizationKey.where(localization_key: key).exists?
  end

  test 'it wont store key if prefix is added to ignored' do
    old_loader = Lit.loader
    key = 'test.of.storge'
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
    first_key = 'test.of.storge'
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
