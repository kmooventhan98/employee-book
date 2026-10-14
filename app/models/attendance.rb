class Attendance < ApplicationRecord
  belongs_to :business
  belongs_to :employee
  belongs_to :work_project, optional: true

  STATUSES = %w[present half_day absent paid_leave].freeze

  validates :date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :employee_id, uniqueness: { scope: :date, message: "already has attendance logged for this date" }

  before_save :compute_wage_amount

  scope :for_date, ->(dt) { where(date: dt) }
  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(date: start_date..start_date.end_of_month)
  }

  def compute_wage_amount
    return unless employee
    self.wage_amount = employee.calculate_day_wage(status, overtime_hours)
  end
end
