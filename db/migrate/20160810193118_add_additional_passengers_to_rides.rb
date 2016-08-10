class AddAdditionalPassengersToRides < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :additional_passengers, :integer, default: 0
  end
end
