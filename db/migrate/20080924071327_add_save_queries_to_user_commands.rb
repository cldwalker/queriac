class AddSaveQueriesToUserCommands < ActiveRecord::Migration
  def self.up
    add_column :user_commands, :save_queries, :boolean, :default=>true
  end

  def self.down
    remove_column :user_commands, :save_queries
  end
end
