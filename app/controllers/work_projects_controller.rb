class WorkProjectsController < ApplicationController
  before_action :require_admin, except: %i[ index show ]
  before_action :set_project, only: %i[ show edit update destroy cost_analysis ]

  def index
    @projects = current_business.work_projects.includes(:client).order(created_at: :desc)
    @active_count = @projects.where(status: ["in_progress", "quoted"]).count
    @completed_count = @projects.where(status: "completed").count

    @total_quoted = @projects.sum(:quoted_price)
    @total_labor_all = current_business.attendances.where.not(work_project_id: nil).sum(:wage_amount)
    @total_expenses_all = current_business.expenses.where.not(work_project_id: nil).sum(:amount)
  end

  def show
    @attendances = @project.attendances.includes(:employee).order(date: :desc)
    @expenses = @project.expenses.includes(:expense_category).order(date: :desc)
    @invoices = @project.invoices.order(issue_date: :desc)

    @labor_cost = @project.total_labor_cost
    @expenses_cost = @project.total_expenses_cost
    @total_cost = @project.total_cost
    @billed_amount = @project.total_billed
    @received_amount = @project.total_received
    @net_profit = @project.net_profit
    @margin = @project.profit_margin_pct

    # Labor breakdown by employee
    @labor_by_employee = @attendances.group_by(&:employee).transform_values do |records|
      {
        days: records.count { |r| r.status == "present" } + (records.count { |r| r.status == "half_day" } * 0.5),
        ot: records.sum(&:overtime_hours),
        cost: records.sum(&:wage_amount)
      }
    end

    # Expense breakdown by category
    @expenses_by_category = @expenses.group_by(&:expense_category).transform_values do |records|
      records.sum(&:amount)
    end
  end

  def new
    @project = current_business.work_projects.build(status: "in_progress", start_date: Date.current)
    @clients = current_business.clients.order(:name)
  end

  def create
    @clients = current_business.clients.order(:name)
    @project = current_business.work_projects.build(project_params)

    resolve_client_from_params

    if @project.save
      redirect_to work_project_path(@project), notice: "Work / Project '#{@project.title}' created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = current_business.clients.order(:name)
  end

  def update
    @clients = current_business.clients.order(:name)

    resolve_client_from_params

    if @project.update(project_params)
      redirect_to work_project_path(@project), notice: "Project details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to work_projects_path, notice: "Project deleted."
  end

  def cost_analysis
    # Dedicated financial export / analysis page
    show
  end

  private

  def resolve_client_from_params
    query = (params[:new_client_name].presence || params[:client_search_query].presence)&.strip
    return if query.blank?

    if params[:work_project][:client_id].blank?
      # Case-insensitive match for existing client
      matched_client = current_business.clients.find_by("LOWER(name) = ?", query.downcase)
      if matched_client
        @project.client = matched_client
      else
        @project.client = current_business.clients.create!(
          name: query,
          phone: params[:new_client_phone].presence,
          company_name: params[:new_client_company].presence
        )
      end
    end
  end

  def set_project
    @project = current_business.work_projects.find(params[:id])
  end

  def project_params
    params.require(:work_project).permit(:title, :client_id, :description, :status, :quoted_price, :start_date, :end_date)
  end
end
