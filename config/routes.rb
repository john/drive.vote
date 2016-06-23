Rails.application.routes.draw do
  
  root 'home#index'
  # resources :users
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  
end
