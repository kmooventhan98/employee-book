  class Expense < ApplicationRecord
  belongs_to :business
  belongs_to :expense_category
  belongs_to :work_project, optional: true
  has_one_attached :receipt

  validates :date, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :for_date, ->(dt) { where(date: dt) }
  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(date: start_date..start_date.end_of_month)
  }
  scope :general_overhead, -> { where(work_project_id: nil) }
  scope :project_specific, -> { where.not(work_project_id: nil) }
  end
