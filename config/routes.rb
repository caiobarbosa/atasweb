require 'api_constraints'

Rails.application.routes.draw do
  root 'sensors#index'

  devise_for :users
  #Pacientes
  resources :patients

  resources :pressures, only: :create
  resources :temperatures, only: :create

  resources :temperature_sensors do
    resources :temperatures, except: :create
  end

  resources :sensors do
    resources :pressures, except: :create
  end

  # Api definition
  namespace :api, defaults: { format: :json }, path: '/' do
                              #constraints: { subdomain: 'api' }, path: '/' do
    scope module: :v1,
              constraints: ApiConstraints.new(version: 1, default: true) do

      #Resources aqui....
      resources :admeasurements, only: [:create]
      get 'admeasurements/current', to: 'admeasurements#show'
      get 'admeasurements/list/:user_id', to: 'admeasurements#index'
      get 'admeasurements/list_temperatures/:user_id', to: 'admeasurements#index_temperatures'
    end
  end
end
