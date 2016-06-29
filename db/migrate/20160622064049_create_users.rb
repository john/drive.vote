class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, :null => false
      t.integer :user_type, :null => false, :default => 0
      
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.integer :agree_to_background_check
      t.integer :accepted_tos
      t.integer :email_list
      
      t.string :phone_number, null: false, default: ""
      t.string :phone_number_normalized
      t.string :image_url, null: false, default: ""
      t.string :primary_language, null: false, default: ""
      t.string :languages_spoken, null: false, default: ""
      t.string :car_make_and_model, null: false, default: "" # for drivers
      t.integer :max_passengers # for drivers--not including driver
      
      t.string :start_drive_time, null: false, default: ""
      t.string :end_drive_time, null: false, default: ""
      
      t.text :description # bio of the user
      t.text :special_requests # needs a carseat, etc
      t.string :address1, null: false, default: ""
      t.string :address2, null: false, default: ""
      t.string :city, null: false, default: ""
      t.string :state, null: false, default: ""
      t.string :postal_code, null: false, default: ""
      t.string :country, null: false, default: ""
      t.decimal :latitude, {:precision=>15, :scale=>10}
      t.decimal :longitude, {:precision=>15, :scale=>10}
      
      # facebook omniauth
      t.string :provider, null: false, default: ""
      t.string :uid, null: false, default: ""
      
      ## Recoverable
      t.string   :reset_password_token, null: false, default: ""
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip, null: false, default: ""
      t.string   :last_sign_in_ip, null: false, default: ""
      
      t.timestamps

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

  end
end
