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

  describe 'when non-OK response comes in from yandex' do
    before do
      Net::HTTP.stubs(:get_response).with(anything).returns(
        OpenStruct.new(body: '{ "code": 401, "message": "Something odd happened" }')
      )
    end

    it 'raises Lit::CloudTranslation::TranslationError' do
      assert_raises Lit::CloudTranslation::TranslationError do
        Lit::CloudTranslation::Providers::Yandex.translate(text: text, to: to)
      end
    end
  end
end
