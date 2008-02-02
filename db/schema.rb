# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 14) do

  create_table "commands", :force => true do |t|
    t.string   "name"
    t.string   "keyword"
    t.text     "url"
    t.text     "description"
    t.string   "kind"
    t.string   "origin",              :default => "hand"
    t.datetime "created_at"
    t.datetime "modified_at"
    t.boolean  "bookmarklet",         :default => false
    t.integer  "user_id"
    t.boolean  "public",              :default => true
    t.boolean  "public_queries",      :default => true
    t.integer  "queries_count_all",   :default => 0
    t.integer  "queries_count_owner", :default => 0
  end

  create_table "queries", :force => true do |t|
    t.string   "command_id"
    t.string   "query_string"
    t.datetime "created_at"
    t.integer  "user_id"
    t.boolean  "run_by_default", :default => false
    t.text     "referrer"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",        :default => 0,  :null => false
    t.integer "taggable_id",   :default => 0,  :null => false
    t.string  "taggable_type", :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "default_command_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "per_page"
  end

end
