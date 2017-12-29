# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: 'homepage#index'

  resources :points, param: 'book_id/:chapter', only: %i[show edit update]

  match 'login', to: 'sessions#new', via: :get
  match 'login', to: 'sessions#create', via: :post
  match 'logout', to: 'sessions#destroy', via: :delete
end
