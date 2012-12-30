Lit::Engine.routes.draw do

  resources :localization_keys, :actions=>[:index, :destroy] do
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
