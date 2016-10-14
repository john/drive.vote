class AddRadiusToRideZone < ActiveRecord::Migration[5.0]
  def change
    add_column :ride_zones, :nearby_radius, :decimal, {:precision=>6, :scale=>2, default: 10.0}
  end
end
