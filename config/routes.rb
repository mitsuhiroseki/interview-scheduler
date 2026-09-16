Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "scheduling#new"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "schedule", to: "scheduling#new", as: :new_schedule

  resources :interviews, only: %i[create index show edit update] do
    member do
      patch :cancel
    end
  end

  resources :availabilities, except: [:show]
end
