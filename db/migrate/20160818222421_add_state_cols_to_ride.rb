class AddStateColsToRide < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :to_state, :string, null: false, default: ""
    add_column :rides, :from_state, :string, null: false, default: ""
  end
end
