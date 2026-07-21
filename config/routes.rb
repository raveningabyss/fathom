Rails.application.routes.draw do

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  constraints subdomain: 'admin' do
    namespace :admin do
      root 'dashboard#index'
      get 'sign_in', to: 'sessions#new'
      post 'sign_in', to: 'sessions#create'
      delete 'sign_out', to: 'sessions#destroy'

      resources :posts, only: [:index, :new]
      get 'media', to: 'media#index'
      get 'analytics', to: 'analytics#index'
      get 'settings', to: 'settings#index'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
