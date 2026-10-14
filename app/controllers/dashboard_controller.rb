class DashboardController < ApplicationController
  def index
    @today = Date.current
    @selected_month = Date.current.beginning_of_month

    # Scoped to current business
    @employees = current_business.employees.active
    @today_attendances = current_business.attendances.where(date: @today).index_by(&:employee_id)

    # Monthly Metrics
    start_of_month = @selected_month
    end_of_month = @selected_month.end_of_month

    @monthly_revenue = current_business.payment_receipts.where(date: start_of_month..end_of_month).sum(:amount)
    @monthly_labor_cost = current_business.attendances.where(date: start_of_month..end_of_month).sum(:wage_amount)
    @monthly_expenses = current_business.expenses.where(date: start_of_month..end_of_month).sum(:amount)
    @monthly_net_profit = @monthly_revenue - (@monthly_labor_cost + @monthly_expenses)

    # Tea & Food specifically for small business owners
    tea_food_cats = current_business.expense_categories.where("name LIKE ? OR name LIKE ?", "%Tea%", "%Food%").pluck(:id)
    @monthly_tea_food_expense = current_business.expenses.where(date: start_of_month..end_of_month, expense_category_id: tea_food_cats).sum(:amount)

    # Active Projects with job costing
    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"]).limit(5)

    # Recent Invoices & Unpaid amounts
    @recent_invoices = current_business.invoices.order(created_at: :desc).limit(5)
    @total_unpaid_invoices = current_business.invoices.where(doc_type: "invoice").sum(:balance_amount)

    # Total unrecovered worker advances
    @total_pending_advances = current_business.advance_payments.where(is_recovered: false).sum(:amount)
  end
end
