class DropSupporters < ActiveRecord::Migration[5.0]
  def up
    drop_table :supporters
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
