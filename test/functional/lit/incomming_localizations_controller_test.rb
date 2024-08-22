require "test_helper"

module Lit
  class IncommingLocalizationsControllerTest < ActionController::TestCase
    fixtures "lit/sources"
    set_fixture_class lit_sources: Lit::Source
    def setup
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      stub_request(:get, "http://testhost.com/lit/api/v1/last_change.json")
        .to_return(body: {last_change: 1.hour.ago.to_fs(:db)}.to_json)
      @source = lit_sources(:test)
    end

    test "should get index" do
      get :index, params: {source_id: @source.id}
      assert_response :success
    end

    test "should properly return to index" do
      get :accept_all, params: {source_id: @source.id}
      assert_response :redirect
    end
  end
end
