Rails.application.routes.draw do

  resources :projects do

    resources :locations

    member do
      get :check_environments_preloaded, :update_project_location, :deploy_location, :deployments
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
