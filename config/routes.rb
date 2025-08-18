Rails.application.routes.draw do
  get "about", to: "about#index"

  get "password", to: "passwords#edit", as: :edit_password
  patch "password", to: "passwords#update"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"

  delete "logout", to: "sessions#destroy"

  # X OAuth routes
  get "auth/x", to: "x_auth#login"
  get "auth/x/callback", to: "x_auth#callback"
  get "auth/x/callback", to: "omniauth/x_auth#callback"


  get "password/reset", to: "password_resets#new", as: :new_password_reset
  post "password/reset", to: "password_resets#create"

  get "password/reset/edit", to: "password_resets#edit", as: :password_reset_edit
  patch "password/reset/edit", to: "password_resets#update"

  resources :x_accounts, only: [:index, :show, :edit, :update, :destroy]
  resources :x_posts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    post :publish, on: :member
  end

  root "main#index"
end
