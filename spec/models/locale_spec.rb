require 'rails_helper'

RSpec.describe Lit::Locale, type: :model do
  describe "just_locale scope" do
    before do
      @locale = Lit::Locale.create(locale: :en)
      locale_pt = Lit::Locale.create(locale: "pt-BR")
    end

    it "return only that locale" do
      I18n.locale = :en
      Lit.init.cache.reset
      expect(Lit::Locale.just_locale(:en)).to match_array [@locale]
    end
  end
end
