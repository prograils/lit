# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud/providers/yandex'
require 'minitest/mock'

require_relative 'examples'

describe Lit::Cloud::Providers::Yandex,
         vcr: {
           match_requests_on: [:method,
                               VCR.request_matchers.uri_without_param(:key)]
         } do
  before do
    ENV.stubs(:[]).with('YANDEX_TRANSLATE_API_KEY').returns('fakekey')
  end

  cloud_provider_examples(Lit::Cloud::Providers::Yandex)
end
