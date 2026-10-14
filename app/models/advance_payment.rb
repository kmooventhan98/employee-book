class AdvancePayment < ApplicationRecord
  belongs_to :business
  belongs_to :employee

  validates :date, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :pending, -> { where(is_recovered: false) }
  scope :recovered, -> { where(is_recovered: true) }
end
