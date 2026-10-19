module SuperAdmin
  class BusinessesController < BaseController
    before_action :set_business, only: %i[ show edit update destroy switch_to resend_welcome_email ]

    def index
      @businesses = Business.order(created_at: :desc)
    end

    def show
      @users = @business.users
      @employees = @business.employees
      @projects = @business.work_projects
      @invoices = @business.invoices
    end

    def new
      @business = Business.new(currency_code: "INR", currency_symbol: "₹")
    end

    def create
      ActiveRecord::Base.transaction do
        @business = Business.new(business_params)
        unless @business.save
          render :new, status: :unprocessable_entity and return
        end

        if params[:owner_email].present? && params[:owner_password].present?
          @owner = @business.users.create!(
            full_name: params[:owner_name].presence || "Business Admin",
            email_address: params[:owner_email].strip.downcase,
            password: params[:owner_password],
            password_confirmation: params[:owner_password],
            role: "admin"
          )
        end
      end

      notice_msg = "Business '#{@business.name}' onboarded successfully!"
      if @owner
        begin
          BusinessMailer.welcome_email(@business, @owner, temporary_password: params[:owner_password]).deliver_now
          notice_msg += " Welcome email sent to #{@owner.email_address}."
        rescue => mail_err
          Rails.logger.error("[BusinessMailer] Failed to send welcome email: #{mail_err.class}: #{mail_err.message}")
          notice_msg += " Note: Welcome email could not be sent (#{mail_err.message}). You can resend it below."
        end
      end

      redirect_to super_admin_business_path(@business), notice: notice_msg
    rescue => e
      flash.now[:alert] = "Failed to onboard business: #{e.message}"
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      if @business.update(business_params)
        redirect_to super_admin_business_path(@business), notice: "Business updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @business.destroy
      redirect_to super_admin_businesses_path, notice: "Business removed."
    end

    def switch_to
      session[:active_business_id] = @business.id
      redirect_to root_path, notice: "Switched to #{@business.name}'s workspace."
    end

    def resend_welcome_email
      @user = @business.users.find(params[:user_id])
      temp_password = params[:temporary_password].presence
      if temp_password.present?
        @user.update!(password: temp_password, password_confirmation: temp_password)
      end

      BusinessMailer.welcome_email(@business, @user, temporary_password: temp_password).deliver_now
      redirect_to super_admin_business_path(@business), notice: "Welcome email sent successfully to #{@user.email_address}!"
    rescue => e
      redirect_to super_admin_business_path(@business), alert: "Failed to send welcome email: #{e.message}"
    end

    private

    def set_business
      @business = Business.find(params[:id])
    end

    def business_params
      params.require(:business).permit(
        :name, :phone, :email, :currency_code, :currency_symbol, :address, :tax_id,
        :invoice_prefix, :quotation_prefix, :google_drive_connected, :google_drive_folder_id
      )
    end
  end
end
