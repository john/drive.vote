class CreateElections < ActiveRecord::Migration[5.0]
  def change
    create_table :elections do |t|
      t.integer :owner_id
      t.string :slug, null: false, default: ""
      t.string :name, null: false, default: ""
      t.text :description
      t.datetime :date

      t.timestamps
    end
  end
end
