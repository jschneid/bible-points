Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'homepage#index'

  get 'points/:book_id/:chapter', to: 'points#show'
  patch 'points/:book_id/:chapter', to: 'points#update'

end
