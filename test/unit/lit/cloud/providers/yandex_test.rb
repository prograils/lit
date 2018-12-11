# frozen_string_literal: true

require 'test_helper'
require 'lit/cloud/providers/yandex'

describe Lit::Cloud::Providers::Yandex, :vcr do
  let(:text) { 'The quick brown fox jumps over the lazy dog.' }
  let(:from) { 'en' }
  let(:to) { 'pl' }

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
      let(:text) { ['awesome', 'stuff'] }

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
      let(:text) { ['awesome', 'stuff'] }

      it 'translates array of strings to target language' do
        subject.length.must_equal 2
      end
    end
  end
end
