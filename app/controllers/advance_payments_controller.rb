class AdvancePaymentsController < ApplicationController
  before_action :require_admin
  before_action :set_employee

  def new
    @advance_payment = @employee.advance_payments.build(
      business: current_business,
      date: Date.current,
      payment_mode: "cash"
    )
  end

  def create
    @advance_payment = @employee.advance_payments.build(advance_params)
    @advance_payment.business = current_business

    if @advance_payment.save
      redirect_to employee_path(@employee), notice: "Advance of #{current_business.formatted_currency(@advance_payment.amount)} logged for #{@employee.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @advance_payment = @employee.advance_payments.find(params[:id])
    @advance_payment.destroy
    redirect_to employee_path(@employee), notice: "Advance entry deleted."
  end

  private

  def set_employee
    @employee = current_business.employees.find(params[:employee_id])
  end

  def advance_params
    params.require(:advance_payment).permit(:date, :amount, :payment_mode, :reason)
  end
end
