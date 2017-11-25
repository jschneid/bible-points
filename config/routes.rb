Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homepage#index'
  # TODO: Is 'show' necessary? Does simple_form_for require it?
  # TODO: REmove these %i
  # TODO: Why does index route  need to be there?
  resources :points, param: 'book_id/:chapter', only: %i[edit update]
#  resources :points, only: %i[update new]
end
