class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  def index
    @month = params[:month].present? ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @start_date = @month.beginning_of_month
    @end_date = @month.end_of_month

    @expenses = current_business.expenses.where(date: @start_date..@end_date).order(date: :desc, created_at: :desc)
    @categories = current_business.expense_categories

    # Summaries
    @total_month_expense = @expenses.sum(:amount)
    @tea_food_expense = @expenses.joins(:expense_category).where("expense_categories.name LIKE ? OR expense_categories.name LIKE ?", "%Tea%", "%Food%").sum(:amount)
    @materials_expense = @expenses.joins(:expense_category).where("expense_categories.name LIKE ?", "%Material%").sum(:amount)
    @transport_expense = @expenses.joins(:expense_category).where("expense_categories.name LIKE ? OR expense_categories.name LIKE ?", "%Fuel%", "%Transport%").sum(:amount)

    @by_category = @expenses.group(:expense_category_id).sum(:amount)
  end

  def show
  end

  def new
    @expense = current_business.expenses.build(
      date: Date.current,
      payment_mode: "cash"
    )
    if params[:category_id].present?
      @expense.expense_category_id = params[:category_id]
    elsif current_business.expense_categories.any?
      @expense.expense_category = current_business.expense_categories.first
    end
    if params[:work_project_id].present?
      @expense.work_project_id = params[:work_project_id]
    end
    @categories = current_business.expense_categories
    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
  end

  def create
    @expense = current_business.expenses.build(expense_params)
    @categories = current_business.expense_categories
    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"])

    if @expense.save
      # If receipt attached and Google Drive connected, sync to user's Google Drive
      if params[:expense][:receipt].present?
        receipt_file = params[:expense][:receipt]
        drive_service = GoogleDriveService.new(current_business)
        result = drive_service.upload_file(
          filename: "receipt_#{@expense.id}_#{receipt_file.original_filename}",
          content: receipt_file.tempfile.read,
          mime_type: receipt_file.content_type
        )
        @expense.update_columns(
          google_drive_file_id: result[:file_id],
          google_drive_file_url: result[:web_view_link]
        )
      end

      redirect_to expenses_path, notice: "Logged expense of #{current_business.formatted_currency(@expense.amount)} (#{@expense.expense_category&.name})."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = current_business.expense_categories
    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
  end

  def update
    if @expense.update(expense_params)
      if params[:expense][:receipt].present?
        receipt_file = params[:expense][:receipt]
        drive_service = GoogleDriveService.new(current_business)
        result = drive_service.upload_file(
          filename: "receipt_#{@expense.id}_#{receipt_file.original_filename}",
          content: receipt_file.tempfile.read,
          mime_type: receipt_file.content_type
        )
        @expense.update_columns(
          google_drive_file_id: result[:file_id],
          google_drive_file_url: result[:web_view_link]
        )
      end
      redirect_to expenses_path, notice: "Expense updated."
    else
      @categories = current_business.expense_categories
      @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: "Expense deleted."
  end

  private

  def set_expense
    @expense = current_business.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:expense_category_id, :work_project_id, :date, :amount, :paid_to, :payment_mode, :notes, :receipt)
  end
end
