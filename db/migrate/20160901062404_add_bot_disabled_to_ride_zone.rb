class AddBotDisabledToRideZone < ActiveRecord::Migration[5.0]
  def change
    add_column :ride_zones, :bot_disabled, :boolean, null: false, default: false
  end
end
