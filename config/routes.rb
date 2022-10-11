Rails.application.routes.draw do
  get 'tests/index'
  get 'tests/authenticate'
  get 'tests/callback'
  get 'tests/add_want'
  get 'tests/edit_want'
  get 'tests/remove_want'
  get 'tests/get_artist'
  get 'tests/whoami'
  get '/about', to: 'welcome#about', as: :about
  get '/erd', to: 'welcome#erd', as: :erd
  resources :videos
  resources :tracks
  resources :genres
  resources :releases
  resources :labels
  resources :artists
  root "welcome#index"
end
