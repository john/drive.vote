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

ActiveRecord::Schema.define(version: 20160622064049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "name",                                                             null: false
    t.integer  "user_type",                                           default: 0,  null: false
    t.string   "email",                                               default: "", null: false
    t.string   "encrypted_password",                                  default: "", null: false
    t.integer  "agree_to_background_check"
    t.integer  "accepted_tos"
    t.integer  "email_list"
    t.integer  "speaks_spanish"
    t.integer  "speaks_english"
    t.string   "phone_number",                                        default: "", null: false
    t.string   "phone_number_normalized"
    t.string   "image_url",                                           default: "", null: false
    t.string   "primary_language",                                    default: "", null: false
    t.string   "languages_spoken",                                    default: "", null: false
    t.string   "car_make_and_model",                                  default: "", null: false
    t.integer  "max_passengers"
    t.time     "start_drive_time"
    t.time     "end_drive_time"
    t.text     "description"
    t.text     "special_requests"
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
    t.string   "reset_password_token",                                default: "", null: false
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                                  default: "", null: false
    t.string   "last_sign_in_ip",                                     default: "", null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
