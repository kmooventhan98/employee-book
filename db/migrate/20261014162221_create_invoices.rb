class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :business, null: false, foreign_key: true
      t.references :client, null: true, foreign_key: true
      t.references :work_project, null: true, foreign_key: true
      t.string :doc_type, default: "invoice"
      t.string :invoice_number, null: false
      t.date :issue_date, null: false
      t.date :due_date
      t.string :status, default: "draft"
      t.decimal :subtotal, precision: 12, scale: 2, default: 0.0
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :tax_amount, precision: 12, scale: 2, default: 0.0
      t.decimal :discount_amount, precision: 12, scale: 2, default: 0.0
      t.decimal :total_amount, precision: 12, scale: 2, default: 0.0
      t.decimal :paid_amount, precision: 12, scale: 2, default: 0.0
      t.decimal :balance_amount, precision: 12, scale: 2, default: 0.0
      t.text :terms
      t.text :notes

      t.timestamps
    end
  end
end
