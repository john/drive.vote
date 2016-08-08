class DropElections < ActiveRecord::Migration[5.0]
  def up
    drop_table :elections
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
