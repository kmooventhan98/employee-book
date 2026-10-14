class Client < ApplicationRecord
  belongs_to :business
  has_many :work_projects, dependent: :nullify
  has_many :invoices, dependent: :nullify

  validates :name, presence: true

  def display_name
    company_name.present? ? "#{name} (#{company_name})" : name
  end
end
