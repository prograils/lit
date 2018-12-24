# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud/providers/google'
require 'minitest/mock'

require_relative 'examples'

describe Lit::Cloud::Providers::Google, vcr: { record: :none } do
  before do
    # comment this stubbing block out, provide a .json keyfile and point to its location
    # via GOOGLE_TRANSLATE_API_KEYFILE env to write tests (also set record: :all)
    Lit::Cloud::Providers::Google.any_instance.stubs(:default_config).returns(
      # rubocop:disable Metrics/LineLength
      keyfile_hash: { 'type' => 'service_account',
                      'project_id' => 'redacted',
                      'private_key_id' => 'redacted',
                      'private_key' => 'redacted',
                      'client_email' => 'redacted@redacted.iam.gserviceaccount.com',
                      'client_id' => 'redacted',
                      'auth_uri' => 'https://accounts.google.com/o/oauth2/auth',
                      'token_uri' => 'https://oauth2.googleapis.com/token',
                      'auth_provider_x509_cert_url' => 'https://www.googleapis.com/oauth2/v1/certs',
                      'client_x509_cert_url' => 'https://www.googleapis.com/robot/v1/metadata/x509/redacted@redacted.iam.gserviceaccount.com' }
      # rubocop:enable Metrics/LineLength
    )
    Google::Cloud::Translate::Credentials.stubs(:new).returns(OpenStruct.new)
  end

  cloud_provider_examples(Lit::Cloud::Providers::Google)
end
