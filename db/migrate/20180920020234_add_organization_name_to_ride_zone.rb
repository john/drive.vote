class AddOrganizationNameToRideZone < ActiveRecord::Migration[5.2]
  def change
    add_column :ride_zones, :organization_name, :string, default: ""
  end
end
