class DashboardController < ApplicationController
  def index
    if super_admin? && current_business.nil?
      redirect_to super_admin_root_path and return
    end

    @today = Date.current
    @selected_month = Date.current.beginning_of_month
    start_of_month = @selected_month
    end_of_month = @selected_month.end_of_month

    if employee?
      # Employee / Normal User Dashboard
      @linked_employee = current_user.employee || current_business.employees.find_by("LOWER(name) = ? OR phone = ?", current_user.full_name.downcase, current_user.email_address)

      if @linked_employee
        @today_att = current_business.attendances.find_by(employee: @linked_employee, date: @today)
        month_atts = @linked_employee.attendances.where(date: start_of_month..end_of_month)
        @days_present = month_atts.where(status: "present").count
        @days_half = month_atts.where(status: "half_day").count
        @my_ot_hours = month_atts.sum(:overtime_hours)
        @my_earnings = month_atts.sum(:wage_amount)
        @my_pending_advance = @linked_employee.total_advances_pending
        @my_recent_attendances = month_atts.order(date: :desc).limit(7)
      end

      @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"]).limit(5)
      @recent_expenses = current_business.expenses.where(date: start_of_month..end_of_month).order(date: :desc).limit(5)
    else
      # Business Owner (Admin) & Super Admin view
      @employees = current_business.employees.active
      @today_attendances = current_business.attendances.where(date: @today).index_by(&:employee_id)

      @monthly_revenue = current_business.payment_receipts.where(date: start_of_month..end_of_month).sum(:amount)
      @monthly_labor_cost = current_business.attendances.where(date: start_of_month..end_of_month).sum(:wage_amount)
      @monthly_expenses = current_business.expenses.where(date: start_of_month..end_of_month).sum(:amount)
      @monthly_net_profit = @monthly_revenue - (@monthly_labor_cost + @monthly_expenses)

      tea_food_cats = current_business.expense_categories.where("name LIKE ? OR name LIKE ?", "%Tea%", "%Food%").pluck(:id)
      @monthly_tea_food_expense = current_business.expenses.where(date: start_of_month..end_of_month, expense_category_id: tea_food_cats).sum(:amount)

      @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"]).limit(5)
      @recent_invoices = current_business.invoices.order(created_at: :desc).limit(5)
      @total_unpaid_invoices = current_business.invoices.where(doc_type: "invoice").sum(:balance_amount)
      @total_pending_advances = current_business.advance_payments.where(is_recovered: false).sum(:amount)
    end
  end
end
