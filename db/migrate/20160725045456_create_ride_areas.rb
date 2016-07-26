class CreateRideAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :ride_areas do |t|
      t.string :slug, null: false, default: ""
      t.string :name, null: false, default: ""
      t.text :description
      t.string :phone_number
      t.string :short_code
      
      t.string :city, null: false, default: ""
      t.string :county, null: false, default: ""
      t.string :state, null: false, default: ""
      t.string :zip, null: false, default: ""
      t.string :country, null: false, default: ""
      t.decimal :latitude, {:precision=>15, :scale=>10}
      t.decimal :longitude, {:precision=>15, :scale=>10}

      t.timestamps
    end
  end
end