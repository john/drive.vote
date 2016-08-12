class AddSpecialRequestsToRides < ActiveRecord::Migration[5.0]
  def change
    add_column :rides, :special_requests, :text
  end
end
