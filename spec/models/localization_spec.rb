require 'rails_helper'

RSpec.describe Lit::Localization, type: :model do
  before do
    @locale = Lit::Locale.create(locale: :en)
    locale_pt = Lit::Locale.create(locale: "pt-BR")
    localization_key = Lit::LocalizationKey.create(localization_key: 'scope.some_text')
    @en_localization = Lit::Localization.create(
      locale: @locale,
      localization_key: localization_key,
      default_value: "Some text"
    )
    @pt_br_localization = Lit::Localization.create(
      locale: locale_pt,
      localization_key: localization_key,
      default_value: "Some text",
      translated_value: "Algum texto"
    )
  end

  describe "without_translation scope" do
    it "return only localization that are nil" do
      I18n.locale = :en
      Lit.init.cache.reset
      lang = Lit::Locale.find_by_locale('en')
      lk = Lit::LocalizationKey.find_by_localization_key('scope.some_text')
      l = Lit::Localization.without_translation.first
      expect(l.default_value).to be_eql "Some text"
      expect(Lit::Localization.without_translation.count).to be_eql 1
    end
  end

  describe "for_locale scope" do
    it "return only localizations of a specific locale" do
      expect(Lit::Localization.for_locale(:en)).to match_array [@en_localization]
    end
  end
end
