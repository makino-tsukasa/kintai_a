Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/users/index_working_on', to: 'users#index_working_on'

  get '/bases', to: 'bases#index'
  post '/bases', to: 'bases#create'
  get 'bases/new', to: 'bases#new'
  get 'bases/:id/edit', to: 'bases#edit'
  patch 'bases/:id', to: 'bases#update'
  delete 'bases/:id', to: 'bases#destroy'
  
  resources :users do
    collection { post :import }
    member do
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    
    resources :attendances, only: :update
  end
end
