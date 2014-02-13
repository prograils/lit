Lit::Engine.routes.draw do


  if Lit.api_enabled
    namespace :api do
      namespace :v1 do
        get '/last_change' => 'localizations#last_change'
        resources :locales, :only=>[:index]
        resources :localization_keys, :only=>[:index]
        resources :localizations, :only=>[:index] do
          get 'last_change', :on=>:collection
        end
      end
    end
  end
  resources :locales, :only=>[:index, :destroy] do
    put :hide, :on=>:member
  end
  resources :localization_keys, :only=>[:index, :destroy] do
    member do
      get :star
    end
    collection do
      get :starred
    end
    resources :localizations, :only=>[:edit, :update] do
      member do
        get :previous_versions
      end
    end
  end
  resources :sources do
    member do
      get :synchronize
      put :touch
    end
    resources :incomming_localizations, :only=>[:index, :destroy] do
      member do
        get :accept
      end
      collection do
        get :accept_all
        post :reject_all
      end
    end
  end

  root :to=>"dashboard#index"
end
