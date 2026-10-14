class User < ApplicationRecord
  has_secure_password
  belongs_to :business
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
