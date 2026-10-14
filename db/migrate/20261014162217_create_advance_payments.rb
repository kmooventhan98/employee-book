class CreateAdvancePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :advance_payments do |t|
      t.references :business, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_mode, default: "cash"
      t.string :reason
      t.boolean :is_recovered, default: false

      t.timestamps
    end
  end
end
