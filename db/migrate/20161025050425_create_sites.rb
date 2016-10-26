class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|
      t.integer :singleton_guard
      t.integer :update_location_interval, default: 60
      t.integer :waiting_rides_interval, default: 15

      t.timestamps
    end
    add_index(:sites, :singleton_guard, unique: true)
  end
end
