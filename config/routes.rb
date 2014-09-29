Rails.application.routes.draw do

  resources :projects do

    resources :locations do
      get :update_distance, :deploy, :deployments
    end

    member do
      get :check_environments_preloaded
    end

    collection do
      get :update_all_projects
    end
  end

  root 'projects#index'

  get '/faye/client.js', to: redirect(SETTINGS['faye_server']+'/client.js')

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'
  end
end
