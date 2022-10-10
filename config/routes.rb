Rails.application.routes.draw do
  resources :videos
  resources :tracks
  resources :genres
  resources :releases
  resources :labels
  resources :artists
  root "welcome#index"
end
