class PaymentReceipt < ApplicationRecord
  belongs_to :invoice
  belongs_to :business

  validates :date, presence: true
  validates :amount, numericality: { greater_than: 0 }

  after_save :sync_invoice!
  after_destroy :sync_invoice!

  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(date: start_date..start_date.end_of_month)
  }

  private

  def sync_invoice!
    return unless invoice
    invoice.recalculate_totals!
    invoice.save(validate: false)
  end
end
