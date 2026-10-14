class WagePayoutsController < ApplicationController
  before_action :set_employee

  def new
    @period_start = params[:period_start].present? ? Date.parse(params[:period_start]) : Date.current.beginning_of_month
    @period_end = params[:period_end].present? ? Date.parse(params[:period_end]) : Date.current

    # Calculate attendances in period
    attendances = @employee.attendances.where(date: @period_start..@period_end)
    @gross_wage = attendances.sum(:wage_amount)
    @days_worked = attendances.where(status: ["present", "half_day"]).count
    @ot_hours = attendances.sum(:overtime_hours)

    # Calculate pending advances
    @pending_advances = @employee.total_advances_pending
    @advances_to_deduct = [@pending_advances, @gross_wage].min
    @suggested_net = [@gross_wage - @advances_to_deduct, 0.0].max

    @wage_payout = @employee.wage_payouts.build(
      business: current_business,
      period_start: @period_start,
      period_end: @period_end,
      gross_wage: @gross_wage,
      advances_deducted: @advances_to_deduct,
      net_paid: @suggested_net,
      payment_date: Date.current,
      payment_mode: "cash"
    )
  end

  def create
    @wage_payout = @employee.wage_payouts.build(payout_params)
    @wage_payout.business = current_business

    ActiveRecord::Base.transaction do
      if @wage_payout.save
        # Mark pending advances as recovered up to advances_deducted
        deducted = @wage_payout.advances_deducted.to_f
        if deducted > 0
          @employee.advance_payments.where(is_recovered: false).order(:date).each do |adv|
            break if deducted <= 0
            if adv.amount <= deducted
              adv.update!(is_recovered: true)
              deducted -= adv.amount
            else
              # partial recovery: adjust amount or mark recovered
              adv.update!(is_recovered: true)
              remaining = adv.amount - deducted
              @employee.advance_payments.create!(
                business: current_business,
                date: adv.date,
                amount: remaining,
                payment_mode: adv.payment_mode,
                reason: "Remaining balance after wage payout deduction on #{Date.current}",
                is_recovered: false
              )
              deducted = 0
            end
          end
        end

        redirect_to employee_path(@employee), notice: "Wage payout of #{current_business.formatted_currency(@wage_payout.net_paid)} disbursed successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def set_employee
    @employee = current_business.employees.find(params[:employee_id])
  end

  def payout_params
    params.require(:wage_payout).permit(:period_start, :period_end, :gross_wage, :advances_deducted, :net_paid, :payment_date, :payment_mode, :notes)
  end
end
