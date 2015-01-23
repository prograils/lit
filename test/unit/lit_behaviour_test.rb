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
    ::Rails.configuration.i18n.stubs(:available_locales).returns(nil)
    I18n.backend.expects(:store_item).times(1)
    I18n.backend.store_translations(:dk, foo: 'foo')
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
