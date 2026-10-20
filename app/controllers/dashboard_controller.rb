class DashboardController < ApplicationController
  def index
    if super_admin? && current_business.nil?
      redirect_to super_admin_root_path and return
    end

    @today = Date.current
    @selected_month = if params[:month].present?
      begin
        Date.parse(params[:month]).beginning_of_month
      rescue ArgumentError
        Date.current.beginning_of_month
      end
    else
      Date.current.beginning_of_month
    end

    @prev_month = @selected_month.prev_month
    @next_month = @selected_month.next_month
    @is_current_month = (@selected_month == Date.current.beginning_of_month)
    @show_cash_flow_pulse = if params[:pulse].present?
      params[:pulse] == "1" || params[:pulse] == "true"
    else
      current_business&.show_cash_flow_pulse? || false
    end

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

      # -------------------------------------------------------------
      # 1. CASH INFLOW & OUTFLOW (Actual Realized Liquid Cash Pulse)
      # -------------------------------------------------------------
      # Cash In: Realized payments collected from clients in this month
      @actual_cash_in = current_business.payment_receipts.where(date: start_of_month..end_of_month).sum(:amount).to_f

      # Cash Out: Disbursed wages + Worker advances disbursed + Petty cash/expenses paid
      @wages_disbursed = current_business.wage_payouts.where(
        "(payment_date BETWEEN :start AND :end) OR (payment_date IS NULL AND date(created_at) BETWEEN :start AND :end)",
        start: start_of_month, end: end_of_month
      ).sum(:net_paid).to_f

      @advances_disbursed = current_business.advance_payments.where(date: start_of_month..end_of_month).sum(:amount).to_f
      @monthly_expenses = current_business.expenses.where(date: start_of_month..end_of_month).sum(:amount).to_f
      @actual_cash_out = @wages_disbursed + @advances_disbursed + @monthly_expenses

      # Net Cash Flow Surplus / Deficit
      @net_cash_flow = @actual_cash_in - @actual_cash_out
      @cash_flow_margin_pct = @actual_cash_in > 0 ? ((@net_cash_flow / @actual_cash_in) * 100).round(1) : 0.0

      # Visual coverage percentages for ratio meter
      total_volume = @actual_cash_in + @actual_cash_out
      if total_volume > 0
        @cash_in_pct = ((@actual_cash_in / total_volume) * 100).round(1)
        @cash_out_pct = (100.0 - @cash_in_pct).round(1)
      else
        @cash_in_pct = 50.0
        @cash_out_pct = 50.0
      end

      # -------------------------------------------------------------
      # 2. ACCRUAL OPERATING P&L (Earned Billing vs Accrued Liabilities)
      # -------------------------------------------------------------
      @monthly_revenue = @actual_cash_in
      @monthly_invoiced = current_business.invoices.where(doc_type: "invoice", issue_date: start_of_month..end_of_month).sum(:total_amount).to_f
      @monthly_labor_cost = current_business.attendances.where(date: start_of_month..end_of_month).sum(:wage_amount).to_f
      @monthly_net_profit = @monthly_revenue - (@monthly_labor_cost + @monthly_expenses)
      @accrual_net_profit = @monthly_invoiced - (@monthly_labor_cost + @monthly_expenses)

      tea_food_cats = current_business.expense_categories.where("name LIKE ? OR name LIKE ?", "%Tea%", "%Food%").pluck(:id)
      @monthly_tea_food_expense = current_business.expenses.where(date: start_of_month..end_of_month, expense_category_id: tea_food_cats).sum(:amount).to_f

      # -------------------------------------------------------------
      # 3. RECEIVABLES AGING & UNCOLLECTED CLIENT DUES
      # -------------------------------------------------------------
      unpaid_invoices_scope = current_business.invoices.where(doc_type: "invoice").where("balance_amount > 0").includes(:client)
      @total_unpaid_invoices = unpaid_invoices_scope.sum(:balance_amount).to_f
      @unpaid_invoices_list = unpaid_invoices_scope.to_a

      @overdue_invoices = @unpaid_invoices_list.select { |inv| inv.due_date.present? && inv.due_date < @today }
      @overdue_amount = @overdue_invoices.sum { |inv| inv.balance_amount.to_f }
      @current_dues_amount = @total_unpaid_invoices - @overdue_amount

      # Priority unpaid list: overdue first, then nearest due date
      @priority_unpaid_invoices = @unpaid_invoices_list.sort_by do |inv|
        [
          inv.due_date.present? && inv.due_date < @today ? 0 : 1,
          inv.due_date || Date.new(9999, 12, 31),
          -inv.balance_amount.to_f
        ]
      end.first(5)

      # Outstanding Worker Advances (Khata)
      @total_pending_advances = current_business.advance_payments.where(is_recovered: false).sum(:amount).to_f

      # -------------------------------------------------------------
      # 4. WORK-WISE PROFITABILITY BREAKDOWN
      # -------------------------------------------------------------
      all_projects = current_business.work_projects.where(status: ["in_progress", "completed", "quoted"]).includes(:client, :attendances, :expenses, :invoices).to_a
      @profitable_projects = all_projects.sort_by { |p| -p.net_profit }
      @active_projects = all_projects.select { |p| %w[in_progress quoted].include?(p.status) }.first(5)

      # -------------------------------------------------------------
      # 5. RECENT ACTIVITY
      # -------------------------------------------------------------
      @recent_invoices = current_business.invoices.order(created_at: :desc).limit(5)
    end
  end
end
