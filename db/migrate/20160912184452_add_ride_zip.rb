class AddRideZip < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :from_zip, :string, null: false, default: ""
    add_column :rides, :to_zip, :string, null: false, default: ""
  end
end
