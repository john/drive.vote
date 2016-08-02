Rails.application.routes.draw do
  
  # get "/auth/auth0/callback" => "auth0#callback"
#   get "/auth/failure" => "auth0#failure"

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  
  require 'sidekiq/web'
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  root 'home#index'
  
  # https://blog.heroku.com/real_time_rails_implementing_websockets_in_rails_5_with_action_cable
  # NOTE: to re-enable you also need to uncomment ./channels in application.js,
  # and the code in /channels/messages.js
  # and the meta tag in application.html.haml
  # and lined in development.rb and production.rb
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  
  resources :campaigns, only: [:index, :show]
  resources :elections, only: [:index, :show]
  
  resources :users do #, only: [:show, :new, :create, :edit, :update]
    get :confirm, on: :member
  end
  match '/confirm' => 'home#confirm', via: :get, as: :confirm
  
  # match '/instructions' => 'home#instructions', via: :get, as: :instructions
  
  
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
    resources :ride_zones, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    resources :rides
    
    resources :users, only: [:edit, :update, :index, :destroy]
  end
  
  match "/:campaign_slug" => 'home#index', via: :get
  
end
