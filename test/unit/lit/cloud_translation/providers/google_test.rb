# frozen_string_literal: true

require "test_helper"
require "lit/cloud_translation/providers/google"
require "google/cloud/translate/v2"
require "minitest/mock"

require_relative "examples"

describe Lit::CloudTranslation::Providers::Google, vcr: {record: :none} do
  before do
    # comment this stubbing block out, provide a .json keyfile and point to its location
    # via GOOGLE_TRANSLATE_API_KEYFILE env to write tests (also set record: :all)
    Lit::CloudTranslation::Providers::Google.any_instance.stubs(:default_config).returns(
      # rubocop:disable Metrics/LineLength
      keyfile_hash: {"type" => "service_account",
                     "project_id" => "redacted",
                     "private_key_id" => "redacted",
                     "private_key" => "redacted",
                     "client_email" => "redacted@redacted.iam.gserviceaccount.com",
                     "client_id" => "redacted",
                     "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
                     "token_uri" => "https://oauth2.googleapis.com/token",
                     "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
                     "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/redacted@redacted.iam.gserviceaccount.com"}
      # rubocop:enable Metrics/LineLength
    )
    Google::Auth::Credentials.stubs(:new).returns(OpenStruct.new)
  end

  cloud_provider_examples(Lit::CloudTranslation::Providers::Google)

  def gtranslate_api_class
    ::Google::Cloud::Translate::V2::Api
  end

  describe "errors" do
    describe "when credentials error occurs" do
      before do
        gtranslate_api_class
          .any_instance.stubs(:translate)
          .raises(Signet::AuthorizationError, "Credentials error")
      end

      it "raises Lit::CloudTranslation::TranslationError" do
        assert_raises Lit::CloudTranslation::TranslationError do
          Lit::CloudTranslation::Providers::Google.translate(text: text, to: to)
        end
      end
    end

    describe "when translation error occurs" do
      before do
        gtranslate_api_class
          .any_instance.stubs(:translate)
          .raises(::Google::Cloud::InternalError, "Google failure")
      end

      it "raises Lit::CloudTranslation::TranslationError" do
        assert_raises Lit::CloudTranslation::TranslationError do
          Lit::CloudTranslation::Providers::Google.translate(text: text, to: to)
        end
      end
    end
  end

  describe "edge cases" do
    describe "when text contains newline characters" do
      let(:text) { "Some longer paragraph text\r\nOne line below" }

      it "translation comes back preserving those characters" do
        result = Lit::CloudTranslation::Providers::Google.translate(text: text, to: "pl")
        assert result.include?("\r\n")
        assert result.include?("tekstu akapitu \r\n Jeden wiersz")
      end
    end
  end
end
