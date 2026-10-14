class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true

  before_save :calculate_total_price

  def calculate_total_price
    self.total_price = (quantity.to_f * unit_price.to_f).round(2)
  end
end
