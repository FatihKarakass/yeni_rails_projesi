Rails.application.routes.draw do
  get "about", to: "about#index"


  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  delete "logout", to: "sessions#destroy"

  root "main#index" 


end

