require "test_helper"

module Lit
  class SourceTest < ActiveSupport::TestCase
    fixtures "lit/sources"
    def setup
      stub_request(:get, "http://testhost.com/lit/api/v1/last_change.json")
        .to_return(body: {last_change: 1.hour.ago.to_fs(:db)}.to_json)
      stub_request(:get, "http://testhost.nope/lit/api/v1/last_change.json")
        .to_return(body: "Nothing to be found around here", status: 404)
    end
    test "validates url validation" do
      s = Lit::Source.new
      s.url = "http://testhost.com/lit"
      s.api_key = "test"
      s.identifier = "test"
      assert s.valid?
      assert s.errors.empty?
      s.url = "http://testhost.nope/lit"
      assert !s.valid?
      assert !s.errors.empty?
    end

    test "touch_last_update_at! updates timestamp" do
      s = lit_sources(:test)
      assert s.last_updated_at < 5.seconds.ago
      previous_updated_at = s.last_updated_at
      s.touch_last_updated_at!
      s.reload
      assert s.last_updated_at > previous_updated_at
    end

    test "should set last_updated_at upon source creation" do
      Lit.set_last_updated_at_upon_creation = true
      s = Lit::Source.new
      s.url = "http://testhost.com/lit"
      s.api_key = "test"
      s.identifier = "test"
      s.save!
      s.reload
      assert s.last_updated_at.present?
    end

    test "should not set last_updated_at upon source creation if asked" do
      Lit.set_last_updated_at_upon_creation = false
      s = Lit::Source.new
      s.url = "http://testhost.com/lit"
      s.api_key = "test"
      s.identifier = "test"
      s.save!
      s.reload
      assert s.last_updated_at.nil?
    end
  end
end
