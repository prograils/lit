require 'test_helper'

module Lit
  class LocalizationsHelperTest < ActionView::TestCase
    include LocalizationsHelper

    test "locales returns available_locale when no current_locale was given" do
      @current_locale = nil
      assert_equal(I18n.available_locales, locales)
    end

    test "locales returns only current_locale when it was given" do
      @current_locale = :en
      assert_equal([:en], locales)
    end
  end
end
