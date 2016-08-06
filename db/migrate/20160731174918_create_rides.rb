class CreateRides < ActiveRecord::Migration[5.0]
  def change
    create_table :rides do |t|
      t.integer :owner_id, null: false
      t.integer :campaign_id
      t.integer :ride_zone_id
      t.string :name, null: false, default: ""
      t.text :description
      t.datetime :pickup_at
      t.integer :status

      t.timestamps
    end
  end
end
