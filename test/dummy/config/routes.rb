Rails.application.routes.draw do
  mount Lit::Engine => "/lit"

  devise_for :admins



  scope "(:locale)", :locale => /en|pl|de/ do
    resources :projects
    get 'welcome'=>"welcome#index", :as=>:welcome
    get 'catan'=>"welcome#catan", :as=>:catan
  end

  root :to=>"welcome#index"

end
