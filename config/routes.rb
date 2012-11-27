Lit::Engine.routes.draw do

  resources :localization_keys do
    resources :localizations
  end

  root :to=>"dashboard#index"
end
