class AddTimeZoneToRideZone < ActiveRecord::Migration[5.0]
  def up
    add_column :ride_zones, :slug, :string
    add_column :ride_zones, :time_zone, :string
    remove_column :ride_zones, :utc_offset, :integer

    add_index :ride_zones, :slug, unique: true
    RideZone.all.each do |rz|
      rz.slug = rz.name.parameterize
      rz.set_time_zone
      rz.save
    end
  end

  def down
    remove_index :ride_zones, :slug
    remove_column :ride_zones, :slug, :string
    remove_column :ride_zones, :time_zone, :string
    add_column :ride_zones, :utc_offset, :integer
  end
end
