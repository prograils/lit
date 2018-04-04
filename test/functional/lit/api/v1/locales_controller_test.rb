require 'test_helper'

module Lit
  class Api::V1::LocalesControllerTest < ActionController::TestCase
    def setup
      Lit.api_enabled = true
      Lit.api_key = 'test'
      @routes = Lit::Engine.routes
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials('test')
    end

    test 'should get index' do
      get :index, format: :json
      assert_response :success
      response.body =~ /en/
      response.body =~ /pl/
    end

    test 'should not get index if api is disabled' do
      Lit.api_enabled = false
      Lit::Engine.routes.clear!
      Dummy::Application.reload_routes!
      @routes = Lit::Engine.routes
      if defined?(ActionController::UrlGenerationError)
        assert_raises(ActionController::UrlGenerationError) do
          get :index, format: :json
        end
      else
        assert_raises(ActionController::RoutingError) do
          get :index, format: :json
        end
      end
    end

    test 'should not be able to access if authorization token is invalid' do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials('invalid')
      get :index, format: :json
      assert_response 401
    end

    test 'should not be able to access if authorization token is missing' do
      request.env.delete('HTTP_AUTHORIZATION')
      get :index, format: :json
      assert_response 401
    end
  end
end
