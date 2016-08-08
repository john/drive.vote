class DropCampaignIdFromRides < ActiveRecord::Migration[5.0]
  def change
    if column_exists?(:rides, :campaign_id)
      remove_column :rides, :campaign_id, :integer
    end
  end
end
