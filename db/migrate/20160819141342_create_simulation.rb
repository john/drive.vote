class CreateSimulation < ActiveRecord::Migration[5.0]
  def change
    create_table :simulations do |t|
      t.integer :status, default: 0, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
