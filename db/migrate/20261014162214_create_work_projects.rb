class CreateWorkProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :work_projects do |t|
      t.references :business, null: false, foreign_key: true
      t.references :client, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, default: "in_progress"
      t.decimal :quoted_price, precision: 12, scale: 2, default: 0.0
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
