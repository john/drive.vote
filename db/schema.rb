# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_03_172250) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blacklisted_phones", id: :serial, force: :cascade do |t|
    t.string "phone"
    t.integer "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_blacklisted_phones_on_phone", unique: true
  end

  create_table "conversations", id: :serial, force: :cascade do |t|
    t.integer "ride_zone_id", null: false
    t.integer "user_id", null: false
    t.string "from_phone", default: "", null: false
    t.string "to_phone", default: "", null: false
    t.integer "status", default: 0, null: false
    t.integer "lifecycle", default: 0, null: false
    t.string "from_address", default: ""
    t.string "from_city", default: ""
    t.string "from_state", default: ""
    t.decimal "from_latitude", precision: 15, scale: 10
    t.decimal "from_longitude", precision: 15, scale: 10
    t.string "to_address", default: ""
    t.string "to_city", default: ""
    t.string "to_state", default: ""
    t.decimal "to_latitude", precision: 15, scale: 10
    t.decimal "to_longitude", precision: 15, scale: 10
    t.datetime "pickup_at"
    t.integer "ride_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "special_requests"
    t.integer "additional_passengers"
    t.integer "bot_counter", default: 0
    t.boolean "ignore_prior_ride"
    t.boolean "from_confirmed"
    t.boolean "to_confirmed"
    t.boolean "time_confirmed"
    t.datetime "status_updated_at"
    t.boolean "ride_confirmed"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "ride_zone_id"
    t.string "to", default: "", null: false
    t.string "from", default: "", null: false
    t.text "body"
    t.string "sms_message_sid", default: "", null: false
    t.string "sms_sid", default: "", null: false
    t.string "sms_status", default: "", null: false
    t.integer "num_media"
    t.integer "num_segments"
    t.string "message_sid", default: "", null: false
    t.string "account_sid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "ride_zones", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "description"
    t.string "phone_number"
    t.string "short_code"
    t.string "city", default: "", null: false
    t.string "county", default: "", null: false
    t.string "state", default: "", null: false
    t.string "zip", default: "", null: false
    t.string "country", default: "", null: false
    t.decimal "latitude", precision: 15, scale: 10
    t.decimal "longitude", precision: 15, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "time_zone"
    t.string "phone_number_normalized"
    t.boolean "bot_disabled", default: false, null: false
    t.decimal "nearby_radius", precision: 6, scale: 2, default: "10.0"
    t.string "email"
    t.decimal "max_pickup_radius", precision: 6, scale: 2, default: "20.0"
    t.index ["phone_number"], name: "index_ride_zones_on_phone_number", unique: true
    t.index ["slug"], name: "index_ride_zones_on_slug", unique: true
  end

  create_table "rides", id: :serial, force: :cascade do |t|
    t.integer "voter_id", null: false
    t.integer "ride_zone_id"
    t.string "name", default: "", null: false
    t.text "description"
    t.datetime "pickup_at"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_id"
    t.decimal "from_latitude", precision: 15, scale: 10
    t.decimal "from_longitude", precision: 15, scale: 10
    t.string "from_address"
    t.decimal "to_latitude", precision: 15, scale: 10
    t.decimal "to_longitude", precision: 15, scale: 10
    t.string "to_address"
    t.integer "additional_passengers", default: 0
    t.text "special_requests"
    t.string "from_city"
    t.string "to_city"
    t.datetime "status_updated_at"
    t.string "to_state", default: "", null: false
    t.string "from_state", default: "", null: false
    t.string "from_zip", default: "", null: false
    t.string "to_zip", default: "", null: false
    t.index ["driver_id"], name: "index_rides_on_driver_id"
    t.index ["ride_zone_id"], name: "index_rides_on_ride_zone_id"
    t.index ["voter_id"], name: "index_rides_on_voter_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "simulations", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.integer "singleton_guard"
    t.integer "update_location_interval", default: 60
    t.integer "waiting_rides_interval", default: 15
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["singleton_guard"], name: "index_sites_on_singleton_guard", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "agree_to_background_check"
    t.integer "accepted_tos"
    t.integer "email_list"
    t.string "phone_number", default: "", null: false
    t.string "phone_number_normalized"
    t.string "image_url", default: "", null: false
    t.string "locale", default: "", null: false
    t.string "languages", default: "", null: false
    t.integer "max_passengers"
    t.time "start_drive_time"
    t.time "end_drive_time"
    t.text "description"
    t.string "address1", default: "", null: false
    t.string "address2", default: "", null: false
    t.string "city", default: "", null: false
    t.string "state", default: "", null: false
    t.string "zip", default: "", null: false
    t.string "country", default: "", null: false
    t.decimal "latitude", precision: 15, scale: 10
    t.decimal "longitude", precision: 15, scale: 10
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", default: "", null: false
    t.string "last_sign_in_ip", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "language", default: 0, null: false
    t.boolean "available", default: false, null: false
    t.datetime "location_updated_at"
    t.string "drivers_license", default: ""
    t.string "license_plate", default: ""
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number_normalized"], name: "index_users_on_phone_number_normalized", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
