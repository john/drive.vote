class AddAvailableToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :available, :boolean, default: false
    add_column :users, :ride_zone_id, :integer
  end
end
