class AddLocationUpdatedAtToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :location_updated_at, :datetime
  end
end
