class RemoveRideIdFromMessages < ActiveRecord::Migration[5.0]

  def change
    remove_column :messages, :ride_id, :integer
  end

end
