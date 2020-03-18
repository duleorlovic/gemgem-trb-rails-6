Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :things do
    resources :comments
    member do
      post :create_comment
      get :next_comments
    end
  end
  root 'things#index'
end
