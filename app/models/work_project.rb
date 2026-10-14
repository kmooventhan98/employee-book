class WorkProject < ApplicationRecord
  belongs_to :business
  belongs_to :client, optional: true
  has_many :attendances, dependent: :nullify
  has_many :expenses, dependent: :nullify
  has_many :invoices, dependent: :nullify

  STATUSES = %w[quoted in_progress completed on_hold cancelled].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: ["in_progress", "quoted"]) }
  scope :completed, -> { where(status: "completed") }

  def total_labor_cost
    attendances.sum(:wage_amount).to_f
  end

  def total_expenses_cost
    expenses.sum(:amount).to_f
  end

  def total_cost
    total_labor_cost + total_expenses_cost
  end

  def total_billed
    inv_total = invoices.where(doc_type: "invoice").sum(:total_amount).to_f
    inv_total > 0 ? inv_total : quoted_price.to_f
  end

  def total_received
    invoices.where(doc_type: "invoice").sum(:paid_amount).to_f
  end

  def net_profit
    total_billed - total_cost
  end

  def profit_margin_pct
    return 0.0 if total_billed <= 0
    ((net_profit / total_billed) * 100.0).round(1)
  end
end
