class AddStateToRide < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :state, :string, null: false, default: ""
  end
end
