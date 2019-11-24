Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/users/index_working_on', to: 'users#index_working_on'
  
  get '/bases', to: 'bases#index'
  get '/bases/edit', to: 'bases#edit'
  patch '/bases/edit', to:'bases#update'
  delete 'bases/destroy', to: 'bases#destroy'
  get 'bases/new', to: 'bases#new'
  post 'bases/new', to: 'bases#create'
  
  resources :users do
    collection { post :import }
    member do
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      # 残業申請用のroute ↓
      get 'edit_extrawork', to: 'attendances#edit_extrawork', as: 'edit_extrawork'
      patch 'update_extrawork', to: 'attendances#update_extrawork', as: 'update_extrawork' 
    end
    
    resources :attendances, only: :update
  end
end
