Rails.application.routes.draw do
  resources :comments, only: [:index, :create, :destroy]
  get "up" => "rails/health#show", as: :rails_health_check
end
