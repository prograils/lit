require 'test_helper'

class I18nBackendTest < ActiveSupport::TestCase
  fixtures 'lit/locales'
  class Backend < Lit::I18nBackend
  end

  def setup
    @old_backend = I18n.backend
    @old_available_locales = ::Rails.configuration.i18n.available_locales
  end

  def teardown
    ::Rails.configuration.i18n.available_locales = @old_available_locales
    I18n.backend = @old_backend
  end

  test 'properly returns available locales' do
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 3, I18n.backend.available_locales.count
    ::Rails.configuration.i18n.available_locales = [:en, :pl]
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 2, I18n.backend.available_locales.count
    ::Rails.configuration.i18n.available_locales = [:en]
    I18n.backend = Backend.new(Lit.loader.cache)
    assert_equal 1, I18n.backend.available_locales.count
  end
end
