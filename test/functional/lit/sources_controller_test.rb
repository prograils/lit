require 'test_helper'
require 'fakeweb'

module Lit
  class SourcesControllerTest < ActionController::TestCase
    fixtures "lit/sources"

    setup do
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      FakeWeb.register_uri(:get, "http://testhost.com/lit/api/v1/last_change.json", :body => {:last_change=>1.hour.ago.to_s(:db)}.to_json)
      @source = lit_sources(:test)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:sources)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create source" do
      assert_difference('Source.count') do
        post :create, :source => { :identifier=>"test2", :url=>"http://testhost.com/lit", :api_key=>"blabla" }
      end
      assert_redirected_to source_path(assigns(:source))
    end

    test "should show source" do
      get :show, :id => @source
      assert_response :success
    end

    test "should get edit" do
      get :edit, :id => @source
      assert_response :success
    end

    test "should update source" do
      put :update, :id => @source, :source => { :identifier=>"test2" }
      assert_redirected_to source_path(assigns(:source))
      @source.reload
      assert "test2", @source.identifier
    end

    test "should destroy source" do
      assert_difference('Source.count', -1) do
        delete :destroy, :id => @source
      end
      assert_redirected_to sources_path
    end
  end
end
