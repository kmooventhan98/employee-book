class CreateWagePayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :wage_payouts do |t|
      t.references :business, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.date :period_start
      t.date :period_end
      t.decimal :gross_wage, precision: 10, scale: 2, default: 0.0
      t.decimal :advances_deducted, precision: 10, scale: 2, default: 0.0
      t.decimal :net_paid, precision: 10, scale: 2, default: 0.0
      t.date :payment_date
      t.string :payment_mode, default: "cash"
      t.string :notes

      t.timestamps
    end
  end
end
