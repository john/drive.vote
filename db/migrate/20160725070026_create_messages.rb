class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.integer :ride_area_id
      t.integer :status, default: 0
      t.string :to, null: false, default: ""
      t.string :to_city, null: false, default: ""
      t.string :to_state, null: false, default: ""
      t.string :to_country, null: false, default: ""
      t.string :to_zip, null: false, default: ""
      
      t.string :from, null: false, default: ""
      t.string :from_city, null: false, default: ""
      t.string :from_state, null: false, default: ""
      t.string :from_country, null: false, default: ""
      t.string :from_zip, null: false, default: ""
      
      t.text :body
      
      t.string :sms_message_sid, null: false, default: ""
      t.string :sms_sid, null: false, default: ""
      t.string :sms_status, null: false, default: ""
      
      t.integer :num_media
      t.integer :num_segments
      t.string :message_sid, null: false, default: ""
      t.string :account_sid, null: false, default: ""

      t.timestamps
    end
  end
end




