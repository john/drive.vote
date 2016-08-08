class AddDrivingColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :driver_id, :integer
    add_column :rides, :from_latitude, :decimal, {:precision=>15, :scale=>10}
    add_column :rides, :from_longitude, :decimal, {:precision=>15, :scale=>10}
    add_column :rides, :from_address, :string
    add_column :rides, :to_latitude, :decimal, {:precision=>15, :scale=>10}
    add_column :rides, :to_longitude, :decimal, {:precision=>15, :scale=>10}
    add_column :rides, :to_address, :string
    add_index :rides, :ride_zone_id
    add_index :rides, :driver_id
  end
end
