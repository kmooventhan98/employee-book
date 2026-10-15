class AllowNullBusinessAndAddEmployeeToUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :business_id, true
    add_reference :users, :employee, null: true, foreign_key: true
  end
end
