class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy convert_to_invoice print ]

  def index
    @doc_type = params[:doc_type]
    @invoices = current_business.invoices.includes(:client, :work_project).order(created_at: :desc)
    @invoices = @invoices.where(doc_type: @doc_type) if @doc_type.present?

    @total_invoiced = current_business.invoices.where(doc_type: "invoice").sum(:total_amount)
    @total_paid = current_business.invoices.where(doc_type: "invoice").sum(:paid_amount)
    @total_due = current_business.invoices.where(doc_type: "invoice").sum(:balance_amount)
    @total_quotes = current_business.invoices.where(doc_type: "quotation").sum(:total_amount)
  end

  def show
    @items = @invoice.invoice_items
    @payments = @invoice.payment_receipts.order(date: :desc)
    @new_payment = @invoice.payment_receipts.build(date: Date.current, amount: @invoice.balance_amount, payment_mode: "cash")
  end

  def new
    doc_type = params[:doc_type] || "invoice"
    prefix = doc_type == "quotation" ? (current_business.quotation_prefix || "EST") : (current_business.invoice_prefix || "INV")
    next_num = "#{prefix}-#{Date.current.year}-%03d" % (current_business.invoices.where(doc_type: doc_type).count + 1)

    @invoice = current_business.invoices.build(
      doc_type: doc_type,
      invoice_number: next_num,
      issue_date: Date.current,
      due_date: Date.current + 15.days,
      client_id: params[:client_id],
      work_project_id: params[:work_project_id],
      tax_rate: 0.0,
      discount_amount: 0.0
    )

    # If work project provided, set initial item
    if @invoice.work_project.present?
      @invoice.invoice_items.build(description: "Work Contract for #{@invoice.work_project.title}", quantity: 1, unit_price: @invoice.work_project.quoted_price)
    else
      @invoice.invoice_items.build(description: "Service / Labor & Materials", quantity: 1, unit_price: 1000.0)
    end

    @clients = current_business.clients.order(:name)
    @projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
  end

  def create
    @clients = current_business.clients.order(:name)
    @projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
    @invoice = current_business.invoices.build(invoice_params)

    if params[:new_client_name].present?
      new_client = current_business.clients.find_or_create_by!(name: params[:new_client_name].strip) do |c|
        c.phone = params[:new_client_phone].presence
        c.company_name = params[:new_client_company].presence
      end
      @invoice.client = new_client
    end

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: "#{@invoice.doc_type.capitalize} #{@invoice.invoice_number} created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = current_business.clients.order(:name)
    @projects = current_business.work_projects.where(status: ["in_progress", "quoted"])
  end

  def update
    @clients = current_business.clients.order(:name)
    @projects = current_business.work_projects.where(status: ["in_progress", "quoted"])

    if params[:new_client_name].present?
      new_client = current_business.clients.find_or_create_by!(name: params[:new_client_name].strip) do |c|
        c.phone = params[:new_client_phone].presence
        c.company_name = params[:new_client_company].presence
      end
      @invoice.client = new_client
    end

    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: "#{@invoice.doc_type.capitalize} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Record removed."
  end

  def convert_to_invoice
    if @invoice.quotation?
      inv_prefix = current_business.invoice_prefix || "INV"
      next_num = "#{inv_prefix}-#{Date.current.year}-%03d" % (current_business.invoices.where(doc_type: "invoice").count + 1)

      @invoice.update!(
        doc_type: "invoice",
        invoice_number: next_num,
        status: "sent",
        issue_date: Date.current,
        due_date: Date.current + 15.days
      )
      redirect_to invoice_path(@invoice), notice: "Quotation successfully converted to Tax Invoice #{@invoice.invoice_number}!"
    else
      redirect_to invoice_path(@invoice), alert: "Document is already an invoice."
    end
  end

  def print
    @items = @invoice.invoice_items
    render layout: false
  end

  private

  def set_invoice
    @invoice = current_business.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :doc_type, :invoice_number, :client_id, :work_project_id, :issue_date, :due_date,
      :status, :tax_rate, :discount_amount, :terms, :notes,
      invoice_items_attributes: [ :id, :description, :quantity, :unit_price, :_destroy ]
    )
  end
end
