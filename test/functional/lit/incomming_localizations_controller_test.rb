require 'test_helper'
require 'fakeweb'

module Lit
  class IncommingLocalizationsControllerTest < ActionController::TestCase
    fixtures 'lit/sources'
    set_fixture_class lit_sources: Lit::Source
    def setup
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      FakeWeb.register_uri(:get, 'http://testhost.com/lit/api/v1/last_change.json', body: { last_change: 1.hour.ago.to_s(:db) }.to_json)
      @source = lit_sources(:test)
    end
    test 'should get index' do
      get :index, source_id: @source.id
      assert_response :success
    end
  end
end
