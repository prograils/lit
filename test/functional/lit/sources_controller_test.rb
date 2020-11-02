require 'test_helper'

module Lit
  class SourcesControllerTest < ActionController::TestCase
    fixtures 'lit/sources'

    setup do
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      stub_request(:get, 'http://testhost.com/lit/api/v1/last_change.json').
        to_return(body: { last_change: 1.hour.ago.to_s(:db) }.to_json)
      @source = lit_sources(:test)
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:sources)
    end

    test 'should get new' do
      get :new
      assert_response :success
    end

    test 'should create source' do
      assert_difference('Source.count') do
        post :create, params: {
                        source: { identifier: 'test2',
                                  url: 'http://testhost.com/lit',
                                  api_key: 'blabla' }
                      }
      end
      assert_redirected_to source_path(assigns(:source))
    end

    test 'should show source' do
      get :show, params: { id: @source }
      assert_response :success
    end

    test 'should get edit' do
      get :edit, params: { id: @source }
      assert_response :success
    end

    test 'should update source' do
        put :update, params: { id: @source, source: { identifier: 'test2' } }
      assert_redirected_to source_path(assigns(:source))
      @source.reload
      assert_equal 'test2', @source.identifier
    end

    test 'should update last_updates_at' do
      prev_last_updated_at = @source.last_updated_at
      put :touch, params: { id: @source }
      assert_redirected_to source_path(assigns(:source))
      @source.reload
      assert_redirected_to @source
      assert @source.last_updated_at > prev_last_updated_at
    end

    test 'should destroy source' do
      assert_difference('Source.count', -1) do
        delete :destroy, params: { id: @source }
      end
      assert_redirected_to sources_path
    end

    test 'should indicate sync completion' do
      @source.update_column(:sync_complete, true)
      get :sync_complete, params: { format: :json, id: @source.id }
      body = JSON.parse(response.body)
      assert_equal true, body['sync_complete']
    end
  end
end
