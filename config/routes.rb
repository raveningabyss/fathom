Rails.application.routes.draw do

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  constraints subdomain: 'admin' do
    get '/', to: redirect('/admin')

    namespace :admin do
      root 'dashboard#index'
      get 'sign_in', to: 'sessions#new'
      post 'sign_in', to: 'sessions#create'
      delete 'sign_out', to: 'sessions#destroy'

      resources :posts do
        resources :media, only: [], controller: 'media' do
          delete 'unlink', on: :member
        end
        resources :categories, only: [], controller: 'categories' do
          delete 'unlink', on: :member
        end
        resources :tags, only: [], controller: 'tags' do
          delete 'unlink', on: :member
        end
      end
      resources :media, only: [:index, :show, :create, :destroy] do
        patch 'mark_as_uploaded'
      end
      resources :categories
      resources :tags
      get 'analytics', to: 'analytics#index'
      get 'settings', to: 'settings#index'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
