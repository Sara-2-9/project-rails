Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # root 'home'
  root 'home#index'

  # Defines the root path route ("/")
  resources :huggingface, only: [:index, :show, :create]

  # Old routes
  # get 'huggingface/index', to: 'huggingface#index'
  # post 'huggingface/create', to: 'huggingface#create', as: 'huggingface_create'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
