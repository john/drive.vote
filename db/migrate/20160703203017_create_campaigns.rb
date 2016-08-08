class CreateCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :campaigns do |t|
      t.integer :owner_id
      t.integer :election_id
      t.string :slug, null: false, default: ""
      t.string :name, null: false, default: ""
      t.integer :party_affiliation
      t.text :description
      t.datetime :start_date

      t.timestamps
    end
    
    add_index :campaigns, :slug, unique: true
  end
end
