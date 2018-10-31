require 'test_helper'

module Lit
  class LocalizationKeysControllerTest < ActionController::TestCase
    fixtures :all

    setup do
      Lit.authentication_function = nil
      I18n.locale = :en
      @routes = Lit::Engine.routes
      @localization_key = lit_localization_keys(:hello_world)
    end

    # GET /localization_keys/not_translated
    test 'should return only not completed localization keys' do
      @localization_key.update is_completed: true
      get :not_translated
      assert_response :success
      assert_not assigns(:localization_keys).include?(
        lit_localization_keys(:hello_world)
      )
    end

    # There where a bug - if someone tries to destroy localization key
    # `Lit.init.cache.delete_key` method is involved. This method was calling
    # `delete` on `@localization_keys` which could be nil and lead to
    # "NoMethodError: undefined method `delete' for nil:NilClass" error. This
    # test ensures lit/localization_keys#destroys works as expected when
    # Lit.loader.cache is a fresh object.

    # DELETE /localization_keys/:id
    test 'should set is_deleted flag of localization key when Lit.loader.cache is fresh object' do
      with_fresh_cache do
        if new_controller_test_format?
          delete :destroy, params: { id: @localization_key.id, format: :js }
        else
          delete :destroy, id: @localization_key.id, format: :js
        end

        assert_response :success
        assert assigns(:localization_key).is_deleted
        assert Lit::LocalizationKey.active.find_by(id: @localization_key.id).blank?
        assert !Lit.init.cache.has_key?("#{I18n.locale}.#{@localization_key.localization_key}")
      end
    end

    # GET /localization_keys
    test 'should find string value' do
      if new_controller_test_format?
        get :index, params: { key: 'value' }
      else
        get :index, key: 'value'
      end
      assert_response :success
      assert assigns(:localization_keys).include?(lit_localization_keys(:string))
      assert_not assigns(:localization_keys).include?(lit_localization_keys(:array))
    end

    # GET /localization_keys
    test 'should find array value' do
      if new_controller_test_format?
        get :index, params: { key: 'two' }
      else
        get :index, key: 'two'
      end
      assert_response :success
      assert_not assigns(:localization_keys).include?(lit_localization_keys(:string))
      assert assigns(:localization_keys).include?(lit_localization_keys(:array))
    end

    # PUT /localization_keys/:id/change_completed
    test 'should change localization key to completed' do
      assert_not @localization_key.is_completed
      if new_controller_test_format?
        put :change_completed, params: { id: @localization_key.id }, format: :js
      else
        put :change_completed, id: @localization_key.id, format: :js
      end
      assert_response :success
      assert @localization_key.reload.is_completed
    end

    # PUT /localization_keys/:id/restore_deleted
    test 'should restore localization key' do
      @localization_key.update is_deleted: true
      if new_controller_test_format?
        put :restore_deleted, params: { id: @localization_key.id }, format: :js
      else
        put :restore_deleted, id: @localization_key.id, format: :js
      end
      assert_response :success
      assert_not @localization_key.reload.is_deleted
    end

    private

    def with_fresh_cache
      old_cache, old_backend = Lit.loader.cache, I18n.backend
      Lit.loader.cache       = Lit::Cache.new
      I18n.backend           = Lit::I18nBackend.new(Lit.loader.cache)

      yield
    ensure
      Lit.loader.cache, I18n.backend = old_cache, old_backend
    end
  end
end
