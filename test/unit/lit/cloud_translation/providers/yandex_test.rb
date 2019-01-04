# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud_translation/providers/yandex'
require 'minitest/mock'

require_relative 'examples'

describe Lit::CloudTranslation::Providers::Yandex,
         vcr: {
           match_requests_on: [:method,
                               VCR.request_matchers.uri_without_param(:key)],
           record: :none # set :all and provide YANDEX_TRANSLATE_API_KEY to write tests
         } do
  cloud_provider_examples(Lit::CloudTranslation::Providers::Yandex)
end
