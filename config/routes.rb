Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  resource :profile, only: [:edit, :update]
  resources :meals, only: [:index, :new, :create, :show] do
    member do
      post :favorite
      post :rate, controller: :ratings, action: :create
      get :ratings, controller: :ratings, action: :index
    end
  end
  resources :favorites, only: [:index, :destroy]
  get "dashboard", to: "dashboard#show"
  get "r/:id/:slug", to: "shared_meals#show", as: :shared_meal
  get "r/:id", to: "shared_meals#show", as: :shared_meal_legacy

  get "up" => "rails/health#show", as: :rails_health_check
end
