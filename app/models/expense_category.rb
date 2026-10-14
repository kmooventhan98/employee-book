class ExpenseCategory < ApplicationRecord
  belongs_to :business
  has_many :expenses, dependent: :restrict_with_error

  validates :name, presence: true
end
