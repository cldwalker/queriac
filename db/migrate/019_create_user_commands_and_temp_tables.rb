class CreateUserCommandsAndTempTables < ActiveRecord::Migration
  def self.up
    create_table "user_commands", :force=>true do |t|
      t.string :name      
      t.string :keyword
      t.text :url
      t.text :description
      t.string   :origin,               :default => "hand"
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :command_id,            :null=>false
      t.integer :user_id,               :null=>false
      t.integer  :queries_count,        :default => 0
      t.boolean  :public_queries,       :default => true
      t.boolean  :http_post,            :default => false
      t.boolean  :url_encode,           :default => true
      t.integer :old_command_id
    end
    
    create_table "temp_commands", :force => true do |t|
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
      t.integer  "queries_count_all",   :default => 0
      t.boolean  "public",              :default => true
      t.boolean  "http_post",           :default => false
      t.boolean  "url_encode",          :default => true
    end
    
    create_table "temp_queries" , :force => true do |t|
      t.string   "command_id"
      t.string   "query_string"
      t.datetime "created_at"
      t.integer  "user_id"
      t.boolean  "run_by_default", :default => false
      t.text     "referrer"
    end    
  end

  def self.down
    drop_table :user_commands
    drop_table :temp_commands
    drop_table :temp_queries
  end
end
