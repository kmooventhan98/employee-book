class Invoice < ApplicationRecord
  belongs_to :business
  belongs_to :client, optional: true
  belongs_to :work_project, optional: true

  has_many :invoice_items, dependent: :destroy, inverse_of: :invoice
  has_many :payment_receipts, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  DOC_TYPES = %w[quotation invoice].freeze
  STATUSES = %w[draft sent accepted partial paid overdue cancelled].freeze

  validates :doc_type, inclusion: { in: DOC_TYPES }
  validates :invoice_number, presence: true
  validates :issue_date, presence: true

  scope :quotations, -> { where(doc_type: "quotation") }
  scope :invoices, -> { where(doc_type: "invoice") }
  scope :unpaid, -> { where(doc_type: "invoice", status: %w[draft sent partial overdue]) }
  scope :paid, -> { where(doc_type: "invoice", status: "paid") }
  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(issue_date: start_date..start_date.end_of_month)
  }

  before_save :recalculate_totals!

  def quotation?
    doc_type == "quotation"
  end

  def invoice?
    doc_type == "invoice"
  end

  def recalculate_totals!
    # calculate subtotal from items if loaded
    if invoice_items.any?
      self.subtotal = invoice_items.reject(&:marked_for_destruction?).sum { |item| (item.quantity.to_f * item.unit_price.to_f) }
    end

    taxable = [ (subtotal.to_f - discount_amount.to_f), 0.0 ].max
    self.tax_amount = (taxable * (tax_rate.to_f / 100.0)).round(2)
    self.total_amount = (taxable + tax_amount.to_f).round(2)

    self.paid_amount = payment_receipts.sum(:amount).to_f
    self.balance_amount = [ (total_amount.to_f - paid_amount.to_f), 0.0 ].max

    if invoice?
      if paid_amount >= total_amount && total_amount > 0
        self.status = "paid"
      elsif paid_amount > 0 && paid_amount < total_amount
        self.status = "partial"
      elsif due_date.present? && due_date < Date.current && status != "paid"
        self.status = "overdue"
      end
    end
  end
end
