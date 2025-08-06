Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :page_carousel_slides
  resources :carousel_slides
  resources :pages
  resources :comm_groups
  resources :collections do
    collection do
      # special route to get collection id number from uid_controller.js
      get 'find_by_name'
    end
  end
  resources :people
  resources :archive_items, only: [:index, :create, :show, :new, :edit, :destroy, :update, :delete] do
    collection do
      post :export_to_csv
    end
    member do
      get 'copy'
      delete 'delete_medium_photo', 'delete_poster_image'
      get :create_uid_pdf
    end
  end
  resources :archive_tags
  resources :locations
  get '/archive_items/sync_search' => 'archive_items#sync_search_strings';

  devise_for :users, :controllers => { :registrations => 'users/registrations', :sessions => 'users/sessions' }
  resources :users, only: [:index]

  namespace :api do
    namespace :v1 do
      get 'archive_items/search'
      get 'archive_items/index'
      get 'archive_items/page_count'
      get 'archive_items/pages_page_count'
      get 'archive_items/pages_index'
      get 'archive_items/timeline'
      get '/archive_items/:id', to: 'archive_items#show'
      get 'pages/index'
      get '/pages/:slug', to: 'pages#show'
      get 'locations/index'
      get 'locations/:name', to: 'locations#show'
      get 'tags/index'
      get 'comm_groups/index'
      get 'people/index'
      get 'carousel_slides/index'
      get 'collections/index'
      get 'page_carousel_slides/index'
      post 'comments', to: 'comments#create'
    end
  end
  root :to => 'archive_items#index'
  # root 'homepage#index'

  get '*all', to: 'archive_items#index', constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
