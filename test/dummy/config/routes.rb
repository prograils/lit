Rails.application.routes.draw do
  mount Lit::Engine => "/lit"

  devise_for :admins



  scope "(:locale)", :locale => /en|pl|de/ do
    resources :projects
    match 'welcome'=>"welcome#index", :as=>:welcome
    match 'catan'=>"welcome#catan", :as=>:welcome
  end

  root :to=>"welcome#index"

end
