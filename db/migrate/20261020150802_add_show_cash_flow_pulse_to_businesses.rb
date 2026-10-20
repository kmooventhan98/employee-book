class AddShowCashFlowPulseToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_column :businesses, :show_cash_flow_pulse, :boolean, default: false, null: false
  end
end
