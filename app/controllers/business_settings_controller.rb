class BusinessSettingsController < ApplicationController
  before_action :require_admin
  def show
    @business = current_business
    @categories = @business.expense_categories
  end

  def edit
    @business = current_business
  end

  def update
    @business = current_business
    if @business.update(business_params)
      redirect_to business_settings_path, notice: "Business settings updated successfully."
    else
      @categories = @business.expense_categories
      render :show, status: :unprocessable_entity
    end
  end

  private

  def business_params
    params.require(:business).permit(
      :name, :phone, :email, :currency_code, :currency_symbol, :address, :tax_id,
      :invoice_prefix, :quotation_prefix, :logo,
      :google_drive_connected, :google_drive_email, :google_drive_folder_id,
      :show_cash_flow_pulse
    )
  end
end
