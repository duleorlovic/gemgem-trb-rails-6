Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :things do
    resources :comments
    member do
      post :create_comment
      get :next_comments
    end
  end

  get  'sessions/sign_up_form'
  post 'sessions/sign_up'
  get  'sessions/sign_out'

  get  'sessions/sign_in_form'
  post 'sessions/sign_in'

  get  'sessions/wake_up_form/:id', controller: :sessions, action: :wake_up_form
  post 'sessions/wake_up/:id', controller: :sessions, action: :wake_up, as: :session_wake_up

  root 'things#index'
end
