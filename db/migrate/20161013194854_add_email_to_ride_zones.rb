class AddEmailToRideZones < ActiveRecord::Migration[5.0]
  def change
    add_column :ride_zones, :email, :string, unique: true
  end
end
