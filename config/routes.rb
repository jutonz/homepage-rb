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

    post "webhooks/todoist", to: "webhooks/todoist#create"
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
        resource :tag_search, only: %i[show], module: :images
      end
      resource :bulk_upload, only: %i[new create]
      resources :tags do
        resources :social_media_links, only: %i[new create edit update destroy]
        resources :auto_add_tags, only: %i[new create destroy]
      end
      resource :tag_search, only: %i[show]
    end
  end

  scope module: :recipes do
    resources :recipe_groups do
      resources :recipes do
        resources :ingredients
      end
    end
  end

  resources :ingredients
  resources :shared_bills do
    scope module: :shared_bills do
      resources :payees, except: :index
    end
  end
  resources :user_groups do
    resources :invitations, only: [:create, :destroy], module: :user_groups
  end

  resources :invitations, only: [:show], param: :token do
    resource :acceptance, only: [:create], module: :invitations
  end

  namespace :settings do
    namespace :api do
      resources :tokens
    end
  end

  resource :home, only: :show

  root to: "homes#show"
end
