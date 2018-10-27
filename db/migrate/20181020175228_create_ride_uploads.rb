class CreateRideUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :ride_uploads do |t|
      t.references :user,         foreign_key: true
      t.references :ride_zone,    foreign_key: true
      t.string :name,             null: false, default: ""
      t.text :description,        null: false, default: ""
      t.integer :status,          null: false, default: 0
      t.integer :total_rows,      null: false, default: 0
      t.integer :successful_rows, null: false, default: 0
      t.string :csv_hash,         null: false, default: ""

      t.timestamps
    end
    
    add_index :ride_uploads, :name, unique: true
  end
end
