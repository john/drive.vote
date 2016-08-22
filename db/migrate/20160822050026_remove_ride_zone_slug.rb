class RemoveRideZoneSlug < ActiveRecord::Migration[5.0]
  def up
    remove_column :ride_zones, :slug, :string

    RideZone.all.each do |rz|
      rz.set_utc_offset
      rz.save
    end
  end

  def down
    add_column :ride_zones, :slug, :string
  end
end
