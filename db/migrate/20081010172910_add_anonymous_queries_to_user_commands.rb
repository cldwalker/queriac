class AddAnonymousQueriesToUserCommands < ActiveRecord::Migration
  def self.up
    add_column :user_commands, :anonymous_queries, :boolean, :default=>true
  end

  def self.down
    remove_column :user_commands, :anonymous_queries
  end
end
