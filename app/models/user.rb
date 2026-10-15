class User < ApplicationRecord
  has_secure_password
  belongs_to :business, optional: true
  belongs_to :employee, optional: true
  has_many :sessions, dependent: :destroy

  ROLES = %w[super_admin admin employee].freeze

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def super_admin?
    role == "super_admin"
  end

  def admin?
    role == "admin" || role == "owner"
  end

  def employee?
    role == "employee"
  end

  def role_title
    case role
    when "super_admin" then "Super Admin (Platform Owner)"
    when "admin", "owner" then "Business Owner (Admin)"
    when "employee" then "Staff / Employee"
    else role.to_s.titleize
    end
  end
end
