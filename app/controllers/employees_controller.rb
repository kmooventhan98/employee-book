class EmployeesController < ApplicationController
  before_action :require_admin
  before_action :set_employee, only: %i[ show edit update destroy ]

  def index
    @employees = current_business.employees.order(:name)
    @total_count = @employees.count
    @active_count = @employees.active.count
    @total_pending_advances = current_business.advance_payments.where(is_recovered: false).sum(:amount)
  end

  def show
    @attendances = @employee.attendances.order(date: :desc).limit(20)
    @advance_payments = @employee.advance_payments.order(date: :desc)
    @wage_payouts = @employee.wage_payouts.order(payment_date: :desc)
    @pending_advances = @employee.total_advances_pending

    # Quick summary of current month's work
    start_of_month = Date.current.beginning_of_month
    @month_attendances = @employee.attendances.where(date: start_of_month..Date.current)
    @days_present = @month_attendances.where(status: "present").count
    @days_half = @month_attendances.where(status: "half_day").count
    @total_ot_hours = @month_attendances.sum(:overtime_hours)
    @accrued_month_wage = @month_attendances.sum(:wage_amount)
  end

  def new
    @employee = current_business.employees.build(wage_type: "daily", status: "active", base_rate: 600.0, overtime_hourly_rate: 100.0)
  end

  def create
    @employee = current_business.employees.build(employee_params)
    if @employee.save
      redirect_to employees_path, notice: "Employee #{@employee.name} added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @employee.update(employee_params)
      redirect_to employee_path(@employee), notice: "Employee details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "Employee removed."
  end

  private

  def set_employee
    @employee = current_business.employees.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:name, :phone, :role_title, :wage_type, :base_rate, :overtime_hourly_rate, :status, :joined_date, :notes)
  end
end
