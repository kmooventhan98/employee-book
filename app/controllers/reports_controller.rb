class ReportsController < ApplicationController
  before_action :require_admin
  def pnl
    @month_date = params[:month].present? ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @start_date = @month_date.beginning_of_month
    @end_date = @month_date.end_of_month

    # 1. Revenue: Collected payments in this month
    @revenue_collected = current_business.payment_receipts.where(date: @start_date..@end_date).sum(:amount)

    # Invoices billed in this month
    @revenue_billed = current_business.invoices.where(doc_type: "invoice", issue_date: @start_date..@end_date).sum(:total_amount)

    # 2. Labor Expenses: Sum of wage amounts from attendances in this month
    @labor_attendances = current_business.attendances.where(date: @start_date..@end_date)
    @labor_cost = @labor_attendances.sum(:wage_amount)
    @total_man_days = @labor_attendances.where(status: "present").count + (@labor_attendances.where(status: "half_day").count * 0.5)
    @total_ot_hours = @labor_attendances.sum(:overtime_hours)

    # 3. Operating & Petty Expenses
    @expenses = current_business.expenses.where(date: @start_date..@end_date)
    @total_expenses = @expenses.sum(:amount)
    @expenses_by_category = @expenses.group_by(&:expense_category).transform_values { |list| list.sum(&:amount) }

    # Tea & Food
    @tea_food = @expenses.joins(:expense_category).where("expense_categories.name LIKE ? OR expense_categories.name LIKE ?", "%Tea%", "%Food%").sum(:amount)

    # Net Profit
    @cash_net_profit = @revenue_collected - (@labor_cost + @total_expenses)
    @accrual_net_profit = @revenue_billed - (@labor_cost + @total_expenses)

    # Previous Month for Comparison
    prev_start = @start_date.prev_month
    prev_end = prev_start.end_of_month
    @prev_revenue = current_business.payment_receipts.where(date: prev_start..prev_end).sum(:amount)
    @prev_labor = current_business.attendances.where(date: prev_start..prev_end).sum(:wage_amount)
    @prev_expenses = current_business.expenses.where(date: prev_start..prev_end).sum(:amount)
    @prev_profit = @prev_revenue - (@prev_labor + @prev_expenses)
  end

  def work_pnl
    @projects = current_business.work_projects.includes(:client, :attendances, :expenses, :invoices).order(created_at: :desc)

    @total_billed_all = @projects.sum(&:total_billed)
    @total_labor_all = @projects.sum(&:total_labor_cost)
    @total_expenses_all = @projects.sum(&:total_expenses_cost)
    @total_cost_all = @total_labor_all + @total_expenses_all
    @total_net_profit_all = @total_billed_all - @total_cost_all
    @overall_margin = @total_billed_all > 0 ? ((@total_net_profit_all / @total_billed_all) * 100).round(1) : 0.0
  end
end
