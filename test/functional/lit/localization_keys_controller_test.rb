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

    # There where a bug - if someone tries to destroy localization key
    # `Lit.init.cache.delete_key` method is involved. This method was calling
    # `delete` on `@localization_keys` which could be nil and lead to
    # "NoMethodError: undefined method `delete' for nil:NilClass" error. This
    # test ensures lit/localization_keys#destroys works as expected when
    # Lit.loader.cache is a fresh object.
    test 'should destroy localization key when Lit.loader.cache is fresh object' do
      with_fresh_cache do
        if new_controller_test_format?
          delete :destroy, params: { id: @localization_key.id, format: :js }
        else
          delete :destroy, id: @localization_key.id, format: :js
        end

        assert_response :success
        assert assigns(:localization_key).destroyed?
        assert Lit::LocalizationKey.where(id: @localization_key.id).first.nil?
        assert !Lit.init.cache.has_key?("#{I18n.locale}.#{@localization_key.localization_key}")
      end
    end

    test 'should find string value' do
      if new_controller_test_format?
        get :index, params: { key: 'value', include_completed: 1 }
      else
        get :index, key: 'value', include_completed: 1
      end
      assert_response :success
      assert assigns(:localization_keys).include?(lit_localization_keys(:string))
      assert_not assigns(:localization_keys).include?(lit_localization_keys(:array))
    end

    test 'should find array value' do
      if new_controller_test_format?
        get :index, params: { key: 'two', include_completed: 1 }
      else
        get :index, key: 'two', include_completed: 1
      end
      assert_response :success
      assert_not assigns(:localization_keys).include?(lit_localization_keys(:string))
      assert assigns(:localization_keys).include?(lit_localization_keys(:array))
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
