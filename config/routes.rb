Rails.application.routes.draw do
  get 'tests/index'
  get 'tests/add_want'
  get 'tests/edit_want'
  get 'tests/remove_want'
  get 'tests/whoami'
  resources :videos
  resources :tracks
  resources :genres
  resources :releases
  resources :labels
  resources :artists
  root "welcome#index"
end
