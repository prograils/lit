require 'rails_helper'

RSpec.describe Lit::LocalizationKey, type: :model do
  describe "nulls_for scope" do
    before do
      locale = Lit::Locale.create(locale: :en)
      locale_pt = Lit::Locale.create(locale: "pt-BR")
      @localization_key = Lit::LocalizationKey.create(localization_key: 'scope.some_text')
      Lit::Localization.create(
        locale: locale,
        localization_key: @localization_key
      )
      Lit::Localization.create(
        locale: locale_pt,
        localization_key: @localization_key,
        default_value: "Some text",
        translated_value: "Algum texto"
      )
    end

    it "return only localization key with null translation for a given locale" do
      I18n.locale = :en
      Lit.init.cache.reset
      lang = Lit::Locale.find_by_locale('en')
      lk = Lit::LocalizationKey.find_by_localization_key('scope.some_text')
      expect(Lit::LocalizationKey.nulls_for(:en)).to match_array [@localization_key]
      expect(Lit::LocalizationKey.nulls_for("pt-BR")).to match_array []
    end
  end
end
