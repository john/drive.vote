class ChangeUserPhoneIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :phone_number_normalized
    add_index :users, [:phone_number_normalized, :name], unique: true
  end
end
