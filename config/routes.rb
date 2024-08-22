Lit::Engine.routes.draw do
  if Lit.api_enabled
    namespace :api do
      namespace :v1 do
        get "/last_change" => "localizations#last_change"
        resources :locales, only: [:index]
        resources :localization_keys, only: [:index]
        resources :localizations, only: [:index] do
          get "last_change", on: :collection
        end
      end
    end
  end
  resources :locales, only: [:index, :destroy] do
    put :hide, on: :member
  end
  resources :localization_keys, only: [:index, :destroy] do
    member do
      get :star
      put :change_completed
      put :restore_deleted
    end
    collection do
      get :starred
      get :find_localization
      get :not_translated
      get :visited_again
      post :batch_touch
    end
    resources :localizations, only: [:edit, :update, :show] do
      member do
        put :change_completed
        get :previous_versions
      end
    end
  end
  resources :sources do
    member do
      get :synchronize
      get :sync_complete
      put :touch
    end
    resources :incomming_localizations, only: [:index, :destroy] do
      member do
        get :accept
      end
      collection do
        get :accept_all
        post :reject_all
      end
    end
  end

  resource :cloud_translation, only: :show

  root to: "dashboard#index"
end
