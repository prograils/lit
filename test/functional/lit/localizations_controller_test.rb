require 'test_helper'

module Lit
  class LocalizationsControllerTest < ActionController::TestCase
    fixtures :all

    setup do
      Lit.loader = nil
      Lit.authentication_function = nil
      Lit.init
      @routes = Lit::Engine.routes
      @localization = lit_localizations(:array)
    end

    test 'should get edit' do
      if new_controller_test_format?
        get :edit,
            params: {
              localization_key_id: @localization.localization_key.id,
              id: @localization.id,
              format: :js
            }
      else
        get :edit,
            localization_key_id: @localization.localization_key.id,
            id: @localization.id,
            format: :js
      end

      assert_response :success
      assert_not_nil assigns(:localization)
    end

    test 'should get previous_versions' do
      if new_controller_test_format?
        get :previous_versions,
            params: {
              localization_key_id: @localization.localization_key.id,
              id: @localization.id,
              format: :js
            }
      else
        get :previous_versions,
            localization_key_id: @localization.localization_key.id,
            id: @localization.id,
            format: :js
      end
      assert_response :success
      assert_not_nil assigns(:localization)
      assert_not_nil assigns(:versions)
    end

    test 'should update localization when translated_value is a string' do
      @localization = lit_localizations(:string)
      @localization.update_attribute(:is_changed, false)
      if new_controller_test_format?
        put :update,
            params: {
              localization_key_id: @localization.localization_key.id,
              id: @localization.id,
              localization: {
                translated_value: 'new-value',
                locale_id: @localization.locale_id
              },
              format: :js
            }
      else
        put :update,
            localization_key_id: @localization.localization_key.id,
            id: @localization.id,
            localization: {
                translated_value: 'new-value',
                locale_id: @localization.locale_id
            },
            format: :js
      end
      assert_response :success
      @localization.reload
      assert_equal 'new-value', @localization.translated_value
      assert_equal true, @localization.is_changed?
    end

    test 'should update localization when translated_value is a array' do
      @localization = lit_localizations(:array)
      if new_controller_test_format?
        put :update,
            params: {
              localization_key_id: @localization.localization_key.id,
              id: @localization.id,
              localization: {
                  translated_value: %w(three two one),
                  locale_id: @localization.locale_id
              },
              format: :js
            }
      else
        put :update,
            localization_key_id: @localization.localization_key.id,
            id: @localization.id,
            localization: {
              translated_value: %w(three two one),
              locale_id: @localization.locale_id
            },
            format: :js
      end
      assert_response :success
      @localization.reload
      assert_equal %w(three two one), @localization.translated_value
    end

    test 'should set is_changed to true' do
      @localization = lit_localizations(:string)
      assert_equal false, @localization.is_changed?
      if new_controller_test_format?
        put :update,
            params: {
              localization_key_id: @localization.localization_key.id,
              id: @localization.id,
              localization: {
                  translated_value: 'new-value',
                  locale_id: @localization.locale_id
              },
              format: :js
            }
      else
        put :update,
            localization_key_id: @localization.localization_key.id,
            id: @localization.id,
            localization: {
                translated_value: 'new-value',
                locale_id: @localization.locale_id
            },
            format: :js
      end

      assert_response :success
      @localization.reload
      assert_equal true, @localization.is_changed?
    end
  end
end
