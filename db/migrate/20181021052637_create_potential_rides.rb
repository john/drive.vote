class CreatePotentialRides < ActiveRecord::Migration[5.2]
  def change
    create_table :potential_rides do |t|
      t.references :ride_zone, foreign_key: true
      t.references :ride_upload, foreign_key: true
      t.references :voter, foreign_key: {to_table: :users}
      t.references :ride
      t.integer :row_number
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :phone_number_normalized
      t.text :description
      t.integer :status
      t.datetime :pickup_at
      t.decimal :from_latitude, precision: 15, scale: 10
      t.decimal :from_longitude, precision: 15, scale: 10
      t.string :from_address
      t.string :from_city
      t.string :from_state
      t.string :from_zip
      t.decimal :to_latitude, precision: 15, scale: 10
      t.decimal :to_longitude, precision: 15, scale: 10
      t.string :to_address
      t.string :to_city
      t.string :to_state
      t.string :to_zip
      t.integer :additional_passengers
      t.text :special_requests
      t.text :notes

      t.timestamps
    end
    
    change_table :rides do |t|
      t.references :potential_ride
    end
    
    change_column_null :conversations, :from_phone, true
    change_column_null :conversations, :to_phone, true
    
  end
end
