Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  root 'home#index'
  
  resources :campaigns, only: [:index, :show]
  resources :elections, only: [:index, :show]
  resources :users
  
  match '/about' => 'home#about', via: :get, as: :about
  match '/instructions' => 'home#instructions', via: :get, as: :instructions
    
  match '/admin' => 'admin/admin#index', via: :get
  namespace :admin do
    match '/' => 'home#index', :via => :get
    resources :elections, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :campaigns, only: [:index, :new, :create, :edit, :update, :destroy]
  end
  
  match "/:campaign_slug" => 'home#index', via: :get
  
end
