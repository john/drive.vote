class CreateSupporters < ActiveRecord::Migration[5.0]
  def change
    create_table :supporters do |t|
      t.integer :user_id
      t.integer :campaign_id
      t.string :locale
      t.string :locale, null: false, default: ""

      t.timestamps
    end
    
    add_index :supporters, :campaign_id
    add_index :supporters, :user_id
  end
end
