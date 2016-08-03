class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|
      t.integer :ride_zone_id, null: false
      t.integer :user_id, null: false
      t.string :from_phone, null: false, default: ''
      t.string :to_phone, null: false, default: ''

      t.integer :status, null: false, default: 0
      t.integer :lifecycle, null: false, default: 0

      t.string :from_address, null: true, default: ''
      t.string :from_city, null: true, default: ''
      t.string :from_state, null: true, default: ''
      t.decimal :from_latitude, precision: 15, scale: 10, null: true
      t.decimal :from_longitude, precision: 15, scale: 10, null: true

      t.string :to_address, null: true, default: ''
      t.string :to_city, null: true, default: ''
      t.string :to_state, null: true, default: ''
      t.decimal :to_latitude, precision: 15, scale: 10, null: true
      t.decimal :to_longitude, precision: 15, scale: 10, null: true

      t.datetime :pickup_time, null: true
      t.integer :ride_id, null: true

      t.timestamps
    end

    add_column :messages, :conversation_id, :integer
    add_index :messages, :conversation_id

    add_column :users, :language, :integer, null: false, default: 0
    add_index :users, :phone_number_normalized, unique: true

    add_index :ride_zones, :phone_number, unique: true
  end
end
