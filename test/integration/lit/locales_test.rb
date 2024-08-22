require "test_helper"

class LocalesTest < ActionDispatch::IntegrationTest
  def setup
    Lit.ignore_yaml_on_startup = false
    Lit.init
  end

  def teardown
    Lit.ignore_yaml_on_startup = nil
  end

  test "should allow hiding locale" do
    Lit.authentication_function = nil
    # visit('/pl/welcome')
    visit("/lit/localization_keys")
    # within('td.locale_row:last-child') do
    # Lit.init.logger.info page.body
    # assert has_content?('pl')
    # end
    assert(all("td.locale_row").last.text =~ /pl/)
    l = Lit::Locale.where(locale: "pl").first
    l.is_hidden = true
    l.save
    visit("/lit/localization_keys")
    assert(!(all("td.locale_row").last.text =~ /pl/))
  end
end
