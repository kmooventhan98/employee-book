class CreateExpenseCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_categories do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.string :color
      t.string :icon

      t.timestamps
    end
  end
end
