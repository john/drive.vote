class AddDriverInfoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :drivers_license, :string, default: ""
    add_column :users, :license_plate, :string, default: ""
  end
end
