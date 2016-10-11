class AddRideConfirmedToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :ride_confirmed, :boolean, null: true
  end
end
