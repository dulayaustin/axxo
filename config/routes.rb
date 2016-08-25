Rails.application.routes.draw do
  resources :visitors, only: [:index] do
    collection do 
      get 'display/:id' => 'visitors#display', :as => 'display'
    end
  end
  root to: 'visitors#index'
end
