class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    @clients = current_business.clients.order(:name)
  end

  def show
    @projects = @client.work_projects.order(created_at: :desc)
    @invoices = @client.invoices.order(issue_date: :desc)
    @total_billed = @invoices.where(doc_type: "invoice").sum(:total_amount)
    @total_paid = @invoices.where(doc_type: "invoice").sum(:paid_amount)
    @total_due = @invoices.where(doc_type: "invoice").sum(:balance_amount)
  end

  def new
    @client = current_business.clients.build
  end

  def create
    @client = current_business.clients.build(client_params)
    if @client.save
      redirect_to clients_path, notice: "Client #{@client.name} added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to client_path(@client), notice: "Client details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Client removed."
  end

  private

  def set_client
    @client = current_business.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :company_name, :phone, :email, :address, :tax_id)
  end
end
