# frozen_string_literal: true

def cloud_provider_examples(described_klass)
  let(:text) { "The quick brown fox jumps over the lazy dog." }
  let(:from) { "en" }
  let(:to) { "pl" }

  describe "when only :to language is given" do
    subject do
      described_klass.translate(text:, to:)
    end

    describe "when single string is given" do
      it "translates single string to target language" do
        _(subject).must_match(/\blis\b/)
      end

      describe "when string contains interpolation" do
        let(:text) { "here is your %{meal}, enjoy" }

        it "does not translate stuff enclosed in %{}" do
          _(subject).must_match(/%{meal}/)
        end
      end
    end

    describe "when array of strings is given" do
      let(:text) { %w[awesome stuff] }

      it "translates array of strings to target language" do
        _(subject.length).must_equal 2
      end
    end

    describe "when array containing nil values is given" do
      let(:text) { [nil, "awesome", nil, "stuff"] }

      it 'translates array to target language, converting nil to ""' do
        _(subject.first).must_equal ""
        _(subject.second).must_be :present?
        _(subject.third).must_equal ""
        _(subject.fourth).must_be :present?
        _(subject.length).must_equal 4
      end
    end
  end

  describe "when :from and :to languages are given" do
    subject do
      described_klass.translate(text:, from:, to:)
    end

    describe "when single string is given" do
      it "translates single string to target language" do
        _(subject).must_match(/\blis\b/)
      end
    end

    describe "when array of strings is given" do
      let(:text) { %w[awesome stuff] }

      it "translates array of strings to target language" do
        _(subject.length).must_equal 2
      end
    end
  end
end
