Rails.application.routes.draw do
  resources :visitors, only: [:index] do
    collection do 
      get :display
    end
  end
  root to: 'visitors#index'
end
