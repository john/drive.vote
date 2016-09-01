class AddNormalizedPhoneRideZone < ActiveRecord::Migration[5.0]
  def change
    add_column :ride_zones, :phone_number_normalized, :string
  end
end
