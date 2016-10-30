class RenameConversationPickupTimeToPickupAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :conversations, :pickup_time, :pickup_at
  end
end
