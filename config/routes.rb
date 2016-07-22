Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  root 'home#index'
  
  resources :campaigns, only: [:index, :show]
  resources :elections, only: [:index, :show]
  
  resources :users do #, only: [:show, :new, :create, :edit, :update]
    get :confirm, on: :member
  end
  match '/confirm' => 'home#confirm', via: :get, as: :confirm
  
  match '/index2' => 'home#index2', via: :get, as: :index2
  match '/instructions' => 'home#instructions', via: :get, as: :instructions
  
  
  match '/about' => 'home#about', via: :get, as: :about
  match '/terms_of_service' => 'home#terms_of_service', via: :get, as: :terms_of_service
    
  match '/admin' => 'admin/admin#index', via: :get
  namespace :admin do
    match '/' => 'home#index', :via => :get
    resources :users, only: [:index, :destroy]
    resources :elections, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :campaigns, only: [:index, :new, :create, :edit, :update, :destroy]
  end
  
  match "/:campaign_slug" => 'home#index', via: :get
  
end
