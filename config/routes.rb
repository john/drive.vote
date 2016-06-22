Rails.application.routes.draw do
  
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  
  get 'home/index'

  root 'home#index'
  
  # get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
