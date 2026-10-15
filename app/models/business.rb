class Business < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :work_projects, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :advance_payments, dependent: :destroy
  has_many :wage_payouts, dependent: :destroy
  has_many :expense_categories, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :payment_receipts, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true

  after_create :create_default_expense_categories

  def formatted_currency(amount)
    "#{currency_symbol || '₹'}#{'%.2f' % (amount || 0)}"
  end

  def logo_initials
    clean = name.to_s.strip
    return "KB" if clean.blank?

    words = clean.split(/\s+/)
    if words.size >= 2
      "#{words[0][0]}#{words[1][0]}".upcase
    elsif words[0].length >= 2
      words[0][0..1].upcase
    else
      words[0][0].upcase
    end
  end

  private

  def create_default_expense_categories
    defaults = [
      { name: "Tea & Refreshments", color: "#f59e0b", icon: "☕" },
      { name: "Food & Meals", color: "#ef4444", icon: "🍲" },
      { name: "Fuel & Transport", color: "#3b82f6", icon: "⛽" },
      { name: "Hardware & Materials", color: "#10b981", icon: "🧱" },
      { name: "Tools & Machinery", color: "#8b5cf6", icon: "🔧" },
      { name: "General Overhead / Misc", color: "#6b7280", icon: "📦" }
    ]

    defaults.each do |cat|
      expense_categories.find_or_create_by!(name: cat[:name]) do |c|
        c.color = cat[:color]
        c.icon = cat[:icon]
      end
    end
  end
end
