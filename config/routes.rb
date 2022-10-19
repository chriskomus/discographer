Rails.application.routes.draw do
  get 'import/index'
  get 'import/authenticate'
  get 'import/callback'
  get 'import/test_connection'
  get 'import/user_info'
  get 'import/import_album_info'
  get 'import/import_album_imageuri'
  get '/about', to: 'welcome#about', as: :about
  get '/erd', to: 'welcome#erd', as: :erd
  resources :videos
  resources :videos
  resources :tracks
  resources :genres
  resources :albums
  resources :labels
  resources :artists
  resources :releases
  root "welcome#index"
end
