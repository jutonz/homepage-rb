Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :api do
    resource :current_ip, only: :show
    resource :current_user, only: :show
    resources :galleries, only: [] do
      scope module: :galleries do
        resources :images, only: %w[create]
      end
    end
  end

  resource :session, only: %i[new destroy] do
    resource :callback, only: :show, controller: "session/callback"
  end

  resource :todo, only: :show do
    scope module: :todo do
      resources :rooms
      resources :tasks do
        scope module: :tasks do
          resource :occurrence, only: %i[create]
        end
      end
    end
  end

  resources :galleries do
    scope module: :galleries do
      resources :images, except: %i[new create] do
        resources :tags, only: %i[create destroy], module: :images
      end
      resource :tag_search, only: %i[show]
      resource :bulk_upload, only: %i[new create]
      resources :tags
    end
  end

  namespace :settings do
    namespace :api do
      resources :tokens
    end
  end

  resource :home, only: :show

  root to: "homes#show"
end
