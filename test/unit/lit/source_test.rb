require 'test_helper'
require 'fakeweb'
module Lit
  class SourceTest < ActiveSupport::TestCase
    def setup
      FakeWeb.register_uri(:get, "http://testhost.com/lit/api/v1/last_change.json", :body => {:last_change=>1.hour.ago.to_s(:db)}.to_json)
    end
    test "validates url validation" do
      s = Lit::Source.new
      s.url = "http://testhost.com/lit"
      s.api_key = "test"
      s.identifier = "test"
      assert s.valid?
      assert s.errors.empty?
      s.url = "http://localhost.dev/lit"
      assert !s.valid?
      assert !s.errors.empty?
    end
  end
end
