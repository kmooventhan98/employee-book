class WagePayout < ApplicationRecord
  belongs_to :business
  belongs_to :employee

  validates :payment_date, presence: true
  validates :net_paid, numericality: { greater_than_or_equal_to: 0 }

  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(payment_date: start_date..start_date.end_of_month)
  }
end
