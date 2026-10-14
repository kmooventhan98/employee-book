class Employee < ApplicationRecord
  belongs_to :business
  has_many :attendances, dependent: :destroy
  has_many :advance_payments, dependent: :destroy
  has_many :wage_payouts, dependent: :destroy

  WAGE_TYPES = %w[daily weekly monthly].freeze
  STATUSES = %w[active inactive].freeze

  validates :name, presence: true
  validates :wage_type, inclusion: { in: WAGE_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :base_rate, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }

  def total_advances_pending
    advance_payments.where(is_recovered: false).sum(:amount)
  end

  def calculate_day_wage(att_status, ot_hours = 0)
    ot_wage = (ot_hours.to_f * (overtime_hourly_rate || 0).to_f)
    case att_status.to_s
    when "present"
      base_rate.to_f + ot_wage
    when "half_day"
      (base_rate.to_f / 2.0) + ot_wage
    when "paid_leave"
      base_rate.to_f
    when "absent"
      0.0
    else
      0.0
    end
  end
end
