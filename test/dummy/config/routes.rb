Rails.application.routes.draw do



  mount Lit::Engine => "/lit"

  devise_for :admins


  Possible_locales = /en|pl|de/

  scope "(:locale)", :locale => Possible_locales do
    resources :projects
    match 'welcome'=>"welcome#index", :as=>:welcome
    match 'catan'=>"welcome#catan", :as=>:welcome
  end

  root :to=>"welcome#index"

end
