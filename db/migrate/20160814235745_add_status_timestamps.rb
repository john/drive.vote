class AddStatusTimestamps < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :status_updated_at, :datetime
    add_column :rides, :status_updated_at, :datetime
  end
end
