require 'test_helper'

module Lit
  class IncommingLocalizationsControllerTest < ActionController::TestCase
    fixtures 'lit/sources'
    set_fixture_class lit_sources: Lit::Source
    def setup
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      stub_request(:get, 'http://testhost.com/lit/api/v1/last_change.json').
        to_return(body: { last_change: 1.hour.ago.to_s(:db) }.to_json)
      @source = lit_sources(:test)
    end

    test 'should get index' do
      if new_controller_test_format?
        get :index, params: { source_id: @source.id }
      else
        get :index, source_id: @source.id
      end
      assert_response :success
    end

    test 'should properly return to index' do
      if new_controller_test_format?
        get :accept_all, params: { source_id: @source.id }
      else
        get :accept_all, source_id: @source.id
      end
      assert_response :redirect
    end
  end
end
