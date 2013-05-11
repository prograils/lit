Lit::Engine.routes.draw do

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
    resources :localizations
  end

  root :to=>"dashboard#index"
end
