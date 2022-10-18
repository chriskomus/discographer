Rails.application.routes.draw do
  get 'tests/index'
  get 'tests/authenticate'
  get 'tests/callback'
  get 'tests/artist_releases'
  get 'tests/artist'
  get 'tests/whoami'
  get '/about', to: 'welcome#about', as: :about
  get '/erd', to: 'welcome#erd', as: :erd
  resources :videos
  resources :tracks
  resources :genres
  resources :albums
  resources :labels
  resources :artists
  resources :releases
  root "welcome#index"
end
