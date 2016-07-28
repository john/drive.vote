Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  root 'home#index'
  
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  
  resources :campaigns, only: [:index, :show]
  resources :elections, only: [:index, :show]
  
  resources :users do #, only: [:show, :new, :create, :edit, :update]
    get :confirm, on: :member
  end
  match '/confirm' => 'home#confirm', via: :get, as: :confirm
  
  match '/instructions' => 'home#instructions', via: :get, as: :instructions
  
  
  match '/about' => 'home#about', via: :get, as: :about
  match '/terms_of_service' => 'home#terms_of_service', via: :get, as: :terms_of_service
  match '/privacy' => 'home#privacy', via: :get, as: :privacy
    
  match '/admin' => 'admin/admin#index', via: :get
  namespace :admin do
    
    post 'twilio/voice' => 'twilio#voice'
    post 'twilio/sms' => 'twilio#sms'
    
    match '/' => 'home#index', :via => :get
    resources :campaigns, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :elections, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :messages, only: [:show, :update]
    resources :ride_areas, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :users, only: [:index, :destroy]
  end
  
  match "/:campaign_slug" => 'home#index', via: :get
  
end
