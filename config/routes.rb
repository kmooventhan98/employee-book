Rails.application.routes.draw do
  root "dashboard#index"

  # Auth & Registration
  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token

  # Business Settings
  resource :business_settings, only: %i[ show edit update ]

  # Labour / Employee Management
  resources :employees do
    resources :advance_payments, only: %i[ new create destroy ]
    resources :wage_payouts, only: %i[ new create show ]
  end

  # Fast Daily Attendance
  resources :attendances do
    collection do
      get :bulk
      post :bulk_update
    end
  end

  # Daily Expenses & Categories
  resources :expenses
  resources :expense_categories, only: %i[ index create destroy ]

  # Works / Projects (Job Costing & Work-wise P&L)
  resources :work_projects do
    member do
      get :cost_analysis
    end
  end

  # Clients & Invoicing / Quotations
  resources :clients
  resources :invoices do
    member do
      post :convert_to_invoice
      get :print
    end
    resources :payment_receipts, only: %i[ create destroy ]
  end

  # P&L Analytics & Financial Reports
  get "reports/pnl", to: "reports#pnl", as: :pnl_report
  get "reports/work_pnl", to: "reports#work_pnl", as: :work_pnl_report

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
