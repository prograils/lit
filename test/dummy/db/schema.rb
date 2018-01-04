# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180101010109) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "lit_incomming_localizations", force: :cascade do |t|
    t.text     "translated_value"
    t.integer  "locale_id"
    t.integer  "localization_key_id"
    t.integer  "localization_id"
    t.string   "locale_str",           limit: 255
    t.string   "localization_key_str", limit: 255
    t.integer  "source_id"
    t.integer  "incomming_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lit_incomming_localizations", ["incomming_id"], name: "index_lit_incomming_localizations_on_incomming_id", using: :btree
  add_index "lit_incomming_localizations", ["locale_id"], name: "index_lit_incomming_localizations_on_locale_id", using: :btree
  add_index "lit_incomming_localizations", ["localization_id"], name: "index_lit_incomming_localizations_on_localization_id", using: :btree
  add_index "lit_incomming_localizations", ["localization_key_id"], name: "index_lit_incomming_localizations_on_localization_key_id", using: :btree
  add_index "lit_incomming_localizations", ["source_id"], name: "index_lit_incomming_localizations_on_source_id", using: :btree

  create_table "lit_locales", force: :cascade do |t|
    t.string   "locale",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_hidden",              default: false
  end

  create_table "lit_localization_keys", force: :cascade do |t|
    t.string   "localization_key", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_completed",                 default: false
    t.boolean  "is_starred",                   default: false
  end

  add_index "lit_localization_keys", ["localization_key"], name: "index_lit_localization_keys_on_localization_key", unique: true, using: :btree

  create_table "lit_localization_versions", force: :cascade do |t|
    t.text     "translated_value"
    t.integer  "localization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lit_localization_versions", ["localization_id"], name: "index_lit_localization_versions_on_localization_id", using: :btree

  create_table "lit_localizations", force: :cascade do |t|
    t.integer  "locale_id"
    t.integer  "localization_key_id"
    t.text     "default_value"
    t.text     "translated_value"
    t.boolean  "is_changed",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lit_localizations", ["locale_id"], name: "index_lit_localizations_on_locale_id", using: :btree
  add_index "lit_localizations", ["localization_key_id"], name: "index_lit_localizations_on_localization_key_id", using: :btree

  create_table "lit_sources", force: :cascade do |t|
    t.string   "identifier",      limit: 255
    t.string   "url",             limit: 255
    t.string   "api_key",         limit: 255
    t.datetime "last_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sync_complete"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
