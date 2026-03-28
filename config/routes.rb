Rails.application.routes.draw do

  concern :list do
    get :list, on: :collection
  end

  namespace :backend do
    namespace :cells do
      resource :cash_forecast_cell, only: :show
      resource :economic_charges_by_activity_cell, only: :show
    end
  end

  namespace :economic do
    resources :dashboards, only: [] do
      collection do
        get :economic
      end
    end
    resource :costs, only: [:show]
    resource :margins, only: [:show] do
      member do
        get :margins_xslx_export
      end
    end
    resource :simulators, only: [:show]
  end

end
