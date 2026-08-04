Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :coaches do
    resources :availabilities
    resources :slots, only: :destroy
  end

  resources :availabilities, only: [] do
    resources :bookings, only: %i[ new create ]
  end

  resources :cancellations, only: %i[ show destroy ], param: :uuid

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "availabilities#index"
end
