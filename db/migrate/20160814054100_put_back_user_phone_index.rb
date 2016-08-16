class PutBackUserPhoneIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, [:phone_number_normalized, :name]
    add_index :users, :phone_number_normalized, unique: true
  end
end
