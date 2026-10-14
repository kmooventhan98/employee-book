class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @business = Business.new(currency_code: "INR", currency_symbol: "₹")
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @business = Business.new(business_params)
      if @business.save
        @user = @business.users.build(user_params.merge(role: "owner"))
        if @user.save
          start_new_session_for @user
          redirect_to root_path, notice: "Welcome to your business OS, #{@user.full_name}!"
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    if @user&.persisted?
      # already redirected
    else
      @user ||= User.new(user_params)
      flash.now[:alert] = (@user.errors.full_messages + (@business&.errors&.full_messages || [])).join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def business_params
    params.require(:business).permit(:name, :phone, :currency_code, :currency_symbol, :address, :tax_id)
  end

  def user_params
    params.require(:user).permit(:full_name, :email_address, :password, :password_confirmation)
  end
end
