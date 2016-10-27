class AddMaxPickupRadiusToRideZone < ActiveRecord::Migration[5.0]
  def change
    add_column :ride_zones, :max_pickup_radius, :decimal, {:precision=>6, :scale=>2, default: 20.0}
  end
end
