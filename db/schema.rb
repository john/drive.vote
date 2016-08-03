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

ActiveRecord::Schema.define(version: 20160803015624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.integer  "owner_id"
    t.integer  "election_id"
    t.string   "slug",              default: "", null: false
    t.string   "name",              default: "", null: false
    t.integer  "party_affiliation"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["slug"], name: "index_campaigns_on_slug", unique: true, using: :btree
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "ride_zone_id",                                          null: false
    t.integer  "user_id",                                               null: false
    t.string   "from_phone",                               default: "", null: false
    t.string   "to_phone",                                 default: "", null: false
    t.integer  "status",                                   default: 0,  null: false
    t.integer  "lifecycle",                                default: 0,  null: false
    t.string   "from_address",                             default: ""
    t.string   "from_city",                                default: ""
    t.string   "from_state",                               default: ""
    t.decimal  "from_latitude",  precision: 15, scale: 10
    t.decimal  "from_longitude", precision: 15, scale: 10
    t.string   "to_address",                               default: ""
    t.string   "to_city",                                  default: ""
    t.string   "to_state",                                 default: ""
    t.decimal  "to_latitude",    precision: 15, scale: 10
    t.decimal  "to_longitude",   precision: 15, scale: 10
    t.datetime "pickup_time"
    t.integer  "ride_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "elections", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "slug",        default: "", null: false
    t.string   "name",        default: "", null: false
    t.text     "description"
    t.datetime "date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "ride_zone_id"
    t.integer  "ride_id"
    t.integer  "status",          default: 0
    t.string   "to",              default: "", null: false
    t.string   "to_city",         default: "", null: false
    t.string   "to_state",        default: "", null: false
    t.string   "to_country",      default: "", null: false
    t.string   "to_zip",          default: "", null: false
    t.string   "from",            default: "", null: false
    t.string   "from_city",       default: "", null: false
    t.string   "from_state",      default: "", null: false
    t.string   "from_country",    default: "", null: false
    t.string   "from_zip",        default: "", null: false
    t.text     "body"
    t.string   "sms_message_sid", default: "", null: false
    t.string   "sms_sid",         default: "", null: false
    t.string   "sms_status",      default: "", null: false
    t.integer  "num_media"
    t.integer  "num_segments"
    t.string   "message_sid",     default: "", null: false
    t.string   "account_sid",     default: "", null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
  end

  create_table "ride_zones", force: :cascade do |t|
    t.string   "slug",                                   default: "", null: false
    t.string   "name",                                   default: "", null: false
    t.text     "description"
    t.string   "phone_number"
    t.string   "short_code"
    t.string   "city",                                   default: "", null: false
    t.string   "county",                                 default: "", null: false
    t.string   "state",                                  default: "", null: false
    t.string   "zip",                                    default: "", null: false
    t.string   "country",                                default: "", null: false
    t.decimal  "latitude",     precision: 15, scale: 10
    t.decimal  "longitude",    precision: 15, scale: 10
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.index ["phone_number"], name: "index_ride_zones_on_phone_number", unique: true, using: :btree
  end

  create_table "rides", force: :cascade do |t|
    t.integer  "owner_id",                  null: false
    t.integer  "campaign_id"
    t.integer  "ride_zone_id"
    t.string   "name",         default: "", null: false
    t.text     "description"
    t.datetime "pickup_at"
    t.integer  "status"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "supporters", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.string   "locale",      default: "", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["campaign_id"], name: "index_supporters_on_campaign_id", using: :btree
    t.index ["user_id"], name: "index_supporters_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                                                             null: false
    t.integer  "user_type"
    t.string   "email",                                               default: "", null: false
    t.string   "encrypted_password",                                  default: "", null: false
    t.integer  "agree_to_background_check"
    t.integer  "accepted_tos"
    t.integer  "email_list"
    t.integer  "party_affiliation"
    t.string   "phone_number",                                        default: "", null: false
    t.string   "phone_number_normalized"
    t.string   "image_url",                                           default: "", null: false
    t.string   "locale",                                              default: "", null: false
    t.string   "languages",                                           default: "", null: false
    t.integer  "max_passengers"
    t.time     "start_drive_time"
    t.time     "end_drive_time"
    t.text     "description"
    t.string   "address1",                                            default: "", null: false
    t.string   "address2",                                            default: "", null: false
    t.string   "city",                                                default: "", null: false
    t.string   "state",                                               default: "", null: false
    t.string   "zip",                                                 default: "", null: false
    t.string   "country",                                             default: "", null: false
    t.decimal  "latitude",                  precision: 15, scale: 10
    t.decimal  "longitude",                 precision: 15, scale: 10
    t.string   "provider",                                            default: "", null: false
    t.string   "uid",                                                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                                  default: "", null: false
    t.string   "last_sign_in_ip",                                     default: "", null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "language",                                            default: 0,  null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["phone_number_normalized"], name: "index_users_on_phone_number_normalized", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
