Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :api do
    resource :current_ip, only: :show
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

  resources :galleries

  resource :home, only: :show

  root to: "homes#show"
end
