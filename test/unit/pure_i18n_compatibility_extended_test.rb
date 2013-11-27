require 'test_helper'

class PureI18nCompatibilityExtendedTest < ActiveSupport::TestCase
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

  test "translations with scope, default and interpolation should use interpolation every time" do
    I18n.backend.store_translations(:en, :'scope.foo' => 'foo %{bar}')

    assert_equal 'foo bar',     I18n.t(:"scope.blank", :default => :'scope.foo', :bar => "bar")
    assert_equal 'foo bar bis', I18n.t(:"scope.blank", :default => :'scope.foo', :bar => "bar bis")

    I18n.backend.store_translations(:en, :'next_scope.foo' => 'foo %{bar}')
    assert_equal 'foo bar',     I18n.t(:blank, :scope => :next_scope, :default => :foo, :bar => "bar")
    assert_equal 'foo bar bis', I18n.t(:blank, :scope => :next_scope, :default => :foo, :bar => "bar bis")
  end

end
