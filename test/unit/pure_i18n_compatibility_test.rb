require "test_helper"

class PureI18nCompatibilityTest < ActiveSupport::TestCase
  class Backend < Lit::I18nBackend
    include I18n::Backend::Pluralization
  end

  def setup
    Lit::Localization.delete_all
    Lit::LocalizationKey.delete_all
    Lit::LocalizationVersion.delete_all

    @old_load_path = I18n.load_path
    @old_humanize_key = Lit.store_humanized_key
    @old_backend = I18n.backend

    I18n.load_path = []
    Lit.store_humanized_key = false
    I18n.backend = Backend.new(Lit.loader.cache)
    super
  end

  def teardown
    Lit.store_humanized_key = @old_humanize_key
    I18n.backend = @old_backend
    I18n.load_path = @old_load_path
    super
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs

  test "make sure we use the Lit::I18n backend" do
    assert_equal Backend, I18n.backend.class
  end
end
