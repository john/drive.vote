class CreateBlacklistedPhones < ActiveRecord::Migration[5.0]
  def change
    create_table :blacklisted_phones do |t|
      t.string :phone
      t.integer :conversation_id

      t.timestamps
    end
    add_index :blacklisted_phones, :phone, unique: true
  end
end
