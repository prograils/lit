require 'rails_helper'

RSpec.describe Lit::LocalizationsHelper, type: :helper do
  describe "locales" do
    context "when a current_locale was setted" do
      before do
        assign(:current_locale, :en)
      end
      it "returns a list containing just that current_locale" do
        expect(helper.locales).to be_eql [:en]
      end
    end

    context "when current_locale is nil" do
      it "returns a list with all available locales" do
        expect(helper.locales).to be_eql I18n.available_locales
      end
    end

    context "when curren_locale is ''" do
      it "returns a list with all available locales" do
        expect(helper.locales).to be_eql I18n.available_locales
      end
    end
  end
end
