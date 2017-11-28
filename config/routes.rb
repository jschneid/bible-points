Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homepage#index'
  resources :points, param: 'book_id/:chapter', only: %i[show edit update]
end
