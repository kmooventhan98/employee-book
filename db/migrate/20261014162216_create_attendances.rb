class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :business, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :work_project, null: true, foreign_key: true
      t.date :date, null: false
      t.string :status, default: "present"
      t.decimal :overtime_hours, precision: 5, scale: 2, default: 0.0
      t.decimal :wage_amount, precision: 10, scale: 2, default: 0.0
      t.string :notes

      t.timestamps
    end
  end
end
