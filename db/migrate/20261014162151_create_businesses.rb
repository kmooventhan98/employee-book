class CreateBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.string :currency_code, default: "INR"
      t.string :currency_symbol, default: "₹"
      t.text :address
      t.string :tax_id
      t.string :invoice_prefix, default: "INV"
      t.string :quotation_prefix, default: "EST"

      t.timestamps
    end
  end
end
