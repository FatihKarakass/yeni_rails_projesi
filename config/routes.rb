Rails.application.routes.draw do
  get "about", to: "about#index"

  get "password", to: "passwords#edit", as: :edit_password
  patch "password", to: "passwords#update"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"

  delete "logout", to: "sessions#destroy"

  get "password/reset", to: "password_resets#new", as: :new_password_reset
  post "password/reset", to: "password_resets#create"

  get "password/reset/edit", to: "password_resets#edit", as: :password_reset_edit
  patch "password/reset/edit", to: "password_resets#update"

  root "main#index"
end
