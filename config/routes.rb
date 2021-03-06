Rails.application.routes.draw do
  resources :visitors, only: [:index] do
    collection do 
      get 'display/:id' => 'visitors#display', :as => 'display'
      get 'category/:name' => 'visitors#category', :as => 'category'
      get 'download/:id' => 'visitors#download', :as => 'download'
    end
  end
  root to: 'visitors#index'
end
