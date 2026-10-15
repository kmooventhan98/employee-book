class PaymentReceiptsController < ApplicationController
  before_action :require_admin
  before_action :set_invoice

  def create
    @payment = @invoice.payment_receipts.build(payment_params)
    @payment.business = current_business

    if @payment.save
      redirect_to invoice_path(@invoice), notice: "Payment of #{current_business.formatted_currency(@payment.amount)} recorded successfully!"
    else
      redirect_to invoice_path(@invoice), alert: "Failed to record payment: #{@payment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @payment = @invoice.payment_receipts.find(params[:id])
    @payment.destroy
    redirect_to invoice_path(@invoice), notice: "Payment entry removed."
  end

  private

  def set_invoice
    @invoice = current_business.invoices.find(params[:invoice_id])
  end

  def payment_params
    params.require(:payment_receipt).permit(:date, :amount, :payment_mode, :transaction_ref, :notes)
  end
end
