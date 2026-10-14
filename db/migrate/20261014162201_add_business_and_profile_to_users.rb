class AddBusinessAndProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :business, null: false, foreign_key: true
    add_column :users, :full_name, :string
    add_column :users, :role, :string, default: "owner"
  end
end
