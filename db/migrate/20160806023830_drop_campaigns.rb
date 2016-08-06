class DropCampaigns < ActiveRecord::Migration[5.0]
  def up
    drop_table :campaigns
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
