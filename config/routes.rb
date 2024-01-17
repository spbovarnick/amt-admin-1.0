Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :page_carousel_slides
  # resources :leadership_roles
  # resources :news_items
  resources :carousel_slides
  resources :pages
  resources :comm_groups
  resources :collections
  resources :people
  resources :archive_items, only: [:index, :create, :show, :new, :edit, :destroy, :update] do
    member do
      get 'copy'
      delete 'delete_medium_photo'
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
      # get 'news_items/index'
      # get 'leadership_roles/index'
      # get 'leadership_roles/board'
      # get 'leadership_roles/staff'
      # get 'page_carousel_slides/index'
      # post 'comments', to: 'comments#create'
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
