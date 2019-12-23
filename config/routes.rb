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
  
  get '/system_info/edit', to: 'static_pages#edit_system_info'
  
  resources :users do
    collection { post :import }
    member do
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      # 残業申請
      get 'extrawork_request', to: 'attendances#edit_extrawork_request'
      patch 'extrawork_request', to: 'attendances#update_extrawork_request'
      # 残業申請承認（上長）
      get 'approve_extrawork_request', to: 'attendances#edit_approve_extrawork_request'
      patch 'approve_extrawork_request', to: 'attendances#update_approve_extrawork_request'
      # 一日分の勤怠変更承認（上長）
      get 'approve_oneday_request', to: 'attendances#edit_approve_oneday_request'
      patch 'approve_oneday_request', to: 'attendances#update_approve_oneday_request'
      # 勤怠変更ログ
      get 'approved_request', to: 'attendances#approved_request'
      # 一ヶ月分の勤怠申請
      patch 'monthly_request', to: 'attendances#monthly_request'
      # 一ヶ月分の勤怠承認（上長）
      get 'approve_monthly_request', to: 'attendances#edit_approve_monthly_request'
      patch 'approve_monthly_request', to: 'attendances#update_approve_monthly_request'
    end
    
    resources :attendances, only: :update
  end
end
