class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :business, null: false, foreign_key: true
      t.references :expense_category, null: false, foreign_key: true
      t.references :work_project, null: true, foreign_key: true
      t.date :date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :paid_to
      t.string :payment_mode, default: "cash"
      t.text :notes

      t.timestamps
    end
  end
end
