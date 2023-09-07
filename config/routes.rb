Rails.application.routes.draw do
  root to: 'products#index'
  resources :products

  post '/webhooks', to: proc { [204, {}, []] } 
end
