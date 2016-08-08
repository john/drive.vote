class DropCampaignIdFromRides < ActiveRecord::Migration[5.0]
  def change
    remove_column :rides, :campaign_id, :integer
  end
end
