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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130923162141) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "lit_locales", :force => true do |t|
    t.string   "locale"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_hidden",  :default => false
  end

  create_table "lit_localization_keys", :force => true do |t|
    t.string   "localization_key"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_completed",     :default => false
    t.boolean  "is_starred",       :default => false
  end

  add_index "lit_localization_keys", ["localization_key"], :name => "index_lit_localization_keys_on_localization_key", :unique => true

  create_table "lit_localization_versions", :force => true do |t|
    t.text     "translated_value"
    t.integer  "localization_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "lit_localization_versions", ["localization_id"], :name => "index_lit_localization_versions_on_localization_id"

  create_table "lit_localizations", :force => true do |t|
    t.integer  "locale_id"
    t.integer  "localization_key_id"
    t.text     "default_value"
    t.text     "translated_value"
    t.boolean  "is_changed",          :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "lit_localizations", ["locale_id"], :name => "index_lit_localizations_on_locale_id"
  add_index "lit_localizations", ["localization_key_id"], :name => "index_lit_localizations_on_localization_key_id"

  create_table "lit_sources", :force => true do |t|
    t.string   "identifier"
    t.string   "url"
    t.string   "api_key"
    t.datetime "last_updated_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
