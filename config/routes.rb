Rails.application.routes.draw do
  root "dashboard#index"

  # Auth & Registration
  resource :session, only: %i[ new create destroy ]
  get "signout", to: "sessions#destroy", as: :signout
  delete "signout", to: "sessions#destroy"
  resource :registration, only: %i[ new create ]
  resources :passwords, param: :token

  # Business Settings
  resource :business_settings, only: %i[ show edit update ]

  # Super Admin Platform Console (Platform Owner)
  namespace :super_admin do
    root to: "dashboard#index"
    resources :businesses do
      member do
        post :switch_to
        post :resend_welcome_email
      end
    end
    resources :users
  end

  # Labour / Employee Management
  resources :employees do
    resources :advance_payments, only: %i[ new create destroy ]
    resources :wage_payouts, only: %i[ new create show ]
  end

  # Fast Daily Attendance & Calendar
  resources :attendances do
    collection do
      get :bulk
      post :bulk_update
      get :calendar
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

  # Local Mailer Web Preview for Development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
