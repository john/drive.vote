Rails.application.routes.draw do

  devise_for :users, controllers: {
    session: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    unlocks: 'users/unlocks'
  }

  # https://blog.heroku.com/real_time_rails_implementing_websockets_in_rails_5_with_action_cable
  # NOTE: to re-enable you also need to uncomment ./channels in application.js,
  # and the code in /channels/messages.js
  # and the meta tag in application.html.haml
  # and lined in development.rb and production.rb
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  require 'sidekiq/web'
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'home#index'

  match '/confirm' => 'home#confirm', via: :get, as: :confirm
  match '/about' => 'home#about', via: :get, as: :about
  match '/code_of_conduct' => 'home#code_of_conduct', via: :get, as: :code_of_conduct
  match '/terms_of_service' => 'home#terms_of_service', via: :get, as: :terms_of_service
  match '/privacy' => 'home#privacy', via: :get, as: :privacy

  resources :dispatch, only: [:show] do
    member do
      get 'drivers' => 'dispatch#drivers'
      get 'map' => 'dispatch#map'
    end
  end

  resources :driving do
    collection do
      get 'demo' => 'driving#demo'
      get 'status' => 'driving#status'
      post 'location' => 'driving#update_location'
      post 'available' => 'driving#available'
      post 'unavailable' => 'driving#unavailable'
      post 'accept_ride' => 'driving#accept_ride'
      post 'unaccept_ride' => 'driving#unaccept_ride'
      post 'pickup_ride' => 'driving#pickup_ride'
      post 'complete_ride' => 'driving#complete_ride'
      get 'waiting_rides' => 'driving#waiting_rides'
      get 'ridezone_stats' => 'driving#ridezone_stats'
    end
  end

  get 'get_a_ride/:ride_zone_id' => 'rides#new'
  get 'conseguir_un_paseo/:ride_zone_id' => 'rides#new'

  resources :rides, only: [:create, :edit, :update]

  resources :users do
    get :confirm, on: :member
  end

  namespace :api do
    namespace :v1, path: '1' do
      post 'twilio/sms' => 'twilio#sms'
      get 'places/search' => 'places#search'

      resources :conversations, only: [:show, :update] do
        member do
          post 'messages' => 'conversations#create_message'
          post 'rides' => 'conversations#create_ride'
          post 'update_attribute' => 'conversations#update_attribute'
        end
      end

      resources :rides, only: [:update_attribute] do
        member do
          post 'update_attribute' => 'rides#update_attribute'
        end
      end

      resources :ride_zones do
        member do
          post 'assign_ride' => 'ride_zones#assign_ride'
          get 'conversations' => 'ride_zones#conversations'
          post 'conversations' => 'ride_zones#create_conversation'
          get 'drivers' => 'ride_zones#drivers'
          get 'rides' => 'ride_zones#rides'
          post 'rides' => 'ride_zones#create_ride'
        end
      end
    end
  end

  match '/admin' => 'admin/admin#index', via: :get
  namespace :admin do
    resources :conversations, only: [:index, :show] do
      member do
        get 'messages' => 'conversations#messages'
        get 'ride_pane' => 'conversations#ride_pane'
        post 'close' => 'conversations#close'
      end
    end
    resources :drivers, only: [:index]
    resources :rides
    resources :ride_zones, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        post 'add_dispatcher'
        post 'add_driver'
        delete 'remove_dispatcher'
        delete 'remove_driver'
      end
    end
    resources :simulations, only: [:index] do
      collection do
        post 'start_new' => 'simulations#start_new'
        post 'clear_all_data' => 'simulations#clear_all_data'
      end
      member do
        post 'stop' => 'simulations#stop'
        delete 'delete' => 'simulations#delete'
      end
    end
    resources :users, only: [:show, :edit, :update, :index, :destroy]
  end

end
