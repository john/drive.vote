class ChangeOwnerIdToVoterId < ActiveRecord::Migration[5.0]
  def change
    rename_column :rides, :owner_id, :voter_id
    add_index :rides, :voter_id, unique: false
  end
end
