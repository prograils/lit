# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud/providers/google'
require 'minitest/mock'

describe Lit::Cloud::Providers::Google, vcr: { record: :none } do
  let(:text) { 'The quick brown fox jumps over the lazy dog.' }
  let(:from) { 'en' }
  let(:to) { 'pl' }

  before do
    Lit::Cloud::Providers::Google.any_instance.stubs(:default_config).returns(
      keyfile_hash: {"type"=>"service_account",
        "project_id"=>"redacted",
        "private_key_id"=>"redacted",
        "private_key"=>"redacted",
        "client_email"=>"redacted@redacted.iam.gserviceaccount.com",
        "client_id"=>"redacted",
        "auth_uri"=>"https://accounts.google.com/o/oauth2/auth",
        "token_uri"=>"https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url"=>"https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url"=>"https://www.googleapis.com/robot/v1/metadata/x509/redacted@redacted.iam.gserviceaccount.com"}
    )
    Google::Cloud::Translate::Credentials.stubs(:new).returns(OpenStruct.new)
  end

  describe 'when only :to language is given' do
    subject do
      Lit::Cloud::Providers::Google.translate(text: text, to: to)
    end

    describe 'when single string is given' do
      it 'translates single string to target language' do
        subject.must_match(/\blis\b/)
      end
    end

    describe 'when array of strings is given' do
      let(:text) { %w[awesome stuff] }

      it 'translates array of strings to target language' do
        subject.length.must_equal 2
      end
    end
  end

  describe 'when :from and :to languages are given' do
    subject do
      Lit::Cloud::Providers::Google.translate(text: text, from: from, to: to)
    end

    describe 'when single string is given' do
      it 'translates single string to target language' do
        subject.must_match(/\blis\b/)
      end
    end

    describe 'when array of strings is given' do
      let(:text) { %w[awesome stuff] }

      it 'translates array of strings to target language' do
        subject.length.must_equal 2
      end
    end
  end
end
