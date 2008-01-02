# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 12) do

  create_table "commands", :force => true do |t|
    t.column "name",                :string
    t.column "keyword",             :string
    t.column "url",                 :text
    t.column "description",         :text
    t.column "kind",                :string
    t.column "origin",              :string,   :default => "hand"
    t.column "created_at",          :datetime
    t.column "modified_at",         :datetime
    t.column "bookmarklet",         :boolean,  :default => false
    t.column "user_id",             :integer
    t.column "public",              :boolean,  :default => true
    t.column "public_queries",      :boolean,  :default => true
    t.column "queries_count",       :integer,  :default => 0
    t.column "queries_count_owner", :integer,  :default => 0
  end

  create_table "queries", :force => true do |t|
    t.column "command_id",     :string
    t.column "query_string",   :string
    t.column "created_at",     :datetime
    t.column "user_id",        :integer
    t.column "run_by_default", :boolean,  :default => false
  end

  create_table "taggings", :force => true do |t|
    t.column "tag_id",        :integer, :default => 0,  :null => false
    t.column "taggable_id",   :integer, :default => 0,  :null => false
    t.column "taggable_type", :string,  :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
    t.column "activation_code",           :string,   :limit => 40
    t.column "activated_at",              :datetime
    t.column "default_command_id",        :integer
    t.column "first_name",                :string
    t.column "last_name",                 :string
    t.column "per_page",                  :integer
  end

end
