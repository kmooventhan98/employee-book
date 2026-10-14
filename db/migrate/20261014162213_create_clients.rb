class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.string :company_name
      t.string :phone
      t.string :email
      t.text :address
      t.string :tax_id

      t.timestamps
    end
  end
end
