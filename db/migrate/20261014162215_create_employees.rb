class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :role_title
      t.string :wage_type, default: "daily"
      t.decimal :base_rate, precision: 10, scale: 2, default: 0.0
      t.decimal :overtime_hourly_rate, precision: 10, scale: 2, default: 0.0
      t.string :status, default: "active"
      t.date :joined_date
      t.text :notes

      t.timestamps
    end
  end
end
