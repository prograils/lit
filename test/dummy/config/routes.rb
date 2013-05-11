Rails.application.routes.draw do
  mount Lit::Engine => "/lit"

  devise_for :admins


  PossibleLocales = /en|pl|de/

  scope "(:locale)", :locale => PossibleLocales do
    resources :projects
    match 'welcome'=>"welcome#index", :as=>:welcome
    match 'catan'=>"welcome#catan", :as=>:welcome
  end

  root :to=>"welcome#index"

end
