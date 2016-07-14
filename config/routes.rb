Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  root 'home#index'
  
  resources :campaigns, only: [:index, :show]
  resources :elections, only: [:index, :show]
  resources :users #, only: [:show, :new, :create, :edit, :update]
  
  match '/about' => 'home#about', via: :get, as: :about
  match '/terms_of_service' => 'home#terms_of_service', via: :get, as: :terms_of_service
  match '/instructions' => 'home#instructions', via: :get, as: :instructions
    
  match '/admin' => 'admin/admin#index', via: :get
  namespace :admin do
    match '/' => 'home#index', :via => :get
    resources :users, only: [:index, :destroy]
    resources :elections, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :campaigns, only: [:index, :new, :create, :edit, :update, :destroy]
  end
  
  match "/:campaign_slug" => 'home#index', via: :get
  
end
