class CreatePaymentReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_receipts do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :amount, precision: 12, scale: 2, default: 0.0
      t.string :payment_mode, default: "cash"
      t.string :transaction_ref
      t.string :notes

      t.timestamps
    end
  end
end
