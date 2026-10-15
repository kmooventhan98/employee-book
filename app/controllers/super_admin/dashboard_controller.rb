module SuperAdmin
  class DashboardController < BaseController
    def index
      @total_businesses = Business.count
      @total_users = User.count
      @total_employees = Employee.count
      @total_projects = WorkProject.count
      @total_invoices_amount = Invoice.where(doc_type: "invoice").sum(:total_amount)
      @total_revenue_collected = PaymentReceipt.sum(:amount)

      @recent_businesses = Business.order(created_at: :desc).limit(10)
    end
  end
end
