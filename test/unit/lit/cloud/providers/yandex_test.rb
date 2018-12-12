# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud/providers/yandex'
require 'minitest/mock'

describe Lit::Cloud::Providers::Yandex,
         vcr: {
           match_requests_on: [:method,
                               VCR.request_matchers.uri_without_param(:key)]
         } do
  let(:text) { 'The quick brown fox jumps over the lazy dog.' }
  let(:from) { 'en' }
  let(:to) { 'pl' }

  before do
    ENV.stubs(:[]).with('YANDEX_TRANSLATE_API_KEY').returns('fakekey')
  end

  describe 'when only :to language is given' do
    subject do
      Lit::Cloud::Providers::Yandex.translate(text: text, to: to)
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
      Lit::Cloud::Providers::Yandex.translate(text: text, from: from, to: to)
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
