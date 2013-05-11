# encoding: utf-8
require 'test_helper'

class LocalesTest < ActionDispatch::IntegrationTest

  test "should allow hiding locale" do
    Lit.authentication_function = nil
    Redis.new.flushall
    Lit.init.cache.reset
    visit('/pl/welcome')
    visit('/lit/localization_keys')
    within('td.locale_row:last-child') do
      assert page.has_content?('pl')
    end
    l = Lit::Locale.where(:locale=>'pl').first
    l.is_hidden = true
    l.save
    visit('/lit/localization_keys')
    within('td.locale_row:last-child') do
      assert !page.has_content?('pl')
    end

  end

end

