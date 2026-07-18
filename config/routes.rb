Rails.application.routes.draw do

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  constraints subdomain: 'admin' do
    scope module: 'admin', as: 'admin' do
      root 'dashboard#index'
      get 'sign_in', to: 'sessions#new'
      post 'sign_in', to: 'sessions#create'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
